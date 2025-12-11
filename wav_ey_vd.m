% Wavelet coherence: Ey (OMNI) x Vd_{mean,storm,total}
clc; clear; close all;

% --- 1) Carregar dados ionosféricos (para criar eixo temporal 5 min)
load('mediasionosfericasARG.mat');  % contém foF2, hF, hmF2
% assumo foF2 tem comprimento N
N = length(foF2);
start_time = datetime('01-Aug-2017 00:00', 'InputFormat', 'dd-MMM-yyyy HH:mm');
iono_time = start_time + minutes(5*(0:(N-1)));   % 5-min grid

% --- 2) Ler arquivo OMNI (formato do seu arquivo)
fid = fopen('dados_Omni_Tratados.txt');
% formato: dia mes ano HH:MM col5 col6 col7 col8 col9 col10
data = textscan(fid, '%d %d %d %s %f %f %f %f %f %f', 'Delimiter', '\t', 'CollectOutput', false);
fclose(fid);

dia = data{1};
mes = data{2};
ano = data{3};
hora_str = data{4};

% quebrar 'HH:MM'
hora_min = split(hora_str, ':');
HR = str2double(hora_min(:,1));
MN = str2double(hora_min(:,2));

% criar datetime do OMNI
omni_time = datetime(ano, mes, dia, HR, MN, zeros(length(dia),1));

% Extrair colunas. Conforme conversamos: Ey é a antepenúltima do arquivo -> data{8}
% Mas para compatibilidade com seu código anterior, podemos montar omni_data:
omni_data = [data{5}, data{6}, data{7}, data{8}, data{9}, data{10}];
omni_names = {'Bz (nT)', 'Vsw (km/s)', 'Density (n/cc)', 'Ey (mV/m)', 'AE (nT)', 'SYM/H (nT)'};

% Checar: Ey está em omni_data(:,4)
Ey_raw = omni_data(:,4);

% --- 3) Ler arquivo drift.dat (Vd's)
disp('Lendo drift.dat ...');
d = importdata('drift.dat');   % assumindo arquivo numérico
Vd_mean  = d(:,3);
Vd_storm = d(:,4);
Vd_total = d(:,5);
PPEF  = d(:,6);
DDEF  = d(:,7);

% criar tempo do drift (15 min)
nV = length(Vd_mean);
startV = datetime(2017,8,1,0,0,0);
Vd_time = startV + minutes(15*(0:(nV-1)));

% --- 4) Interpolar Ey e Vd's para o grid ionosférico (5 min)
% Primeiro: Ey (alguns NaN presentes)
% transformar omni_time e Ey_raw para numéricos para interp1
x_omni = datenum(omni_time);
xq = datenum(iono_time);   % pontos alvo

Ey_interp = interp1(x_omni, Ey_raw, xq, 'linear', NaN);  % mantém NaN onde extrapolação/sem dado

% Interpolar Vd para grid 5-min
x_vd = datenum(Vd_time);
Vd_mean_interp  = interp1(x_vd, Vd_mean,  xq, 'linear', NaN);
Vd_storm_interp = interp1(x_vd, Vd_storm, xq, 'linear', NaN);
Vd_total_interp = interp1(x_vd, Vd_total, xq, 'linear', NaN);
PPEF_interp = interp1(x_vd, PPEF, xq, 'linear', NaN);
DDEF_interp = interp1(x_vd, DDEF, xq, 'linear', NaN);

% Put signals into a cell for looping
signals = {
    Vd_mean_interp, 'Vd_{mean}';
    Vd_storm_interp, 'Vd_{storm}';
    Vd_total_interp, 'Vd_{total}';
    PPEF_interp,     'PPEF';
    DDEF_interp,     'DDEF';
};


% --- 5) Parâmetros para wcoherence
fs = 1/300;            % sampling frequency em Hz (1 amostra a cada 300 s = 5 min)
dt_seconds = 300;      % usado apenas para referência se necessário

% loop sobre Vd signals -> compute wcoherence(Ey, Vd_k)
for k = 1:size(signals, 1)
    sig_vd = signals{k,1};
    nome_vd = signals{k,2};
    
    sig1 = Ey_interp(:);  % Ey
    sig2 = sig_vd(:);     % Vd or PPEF or DDEF
    
    fprintf('>> %s: Ey pontos válidos = %d / %d ; %s válidos = %d / %d\n', ...
        'Ey vs Signal', sum(isfinite(sig1)), length(sig1), nome_vd, sum(isfinite(sig2)), length(sig2));
    
    % preparar sinais para wcoherence: substituir NaN por 0 apenas para cálculo,
    % mas vamos manter máscara para zerar coerência depois
    mask_nan = isnan(sig1) | isnan(sig2);
    sig1_clean = sig1;
    sig2_clean = sig2;
    sig1_clean(isnan(sig1_clean)) = 0;
    sig2_clean(isnan(sig2_clean)) = 0;
    
    % extensão simétrica (espelhada) para minimizar efeitos de borda
    left1 = flipud(sig1_clean);
    sig1_ext = [left1; left1; sig1_clean; left1; left1];
    
    left2 = flipud(sig2_clean);
    sig2_ext = [left2; left2; sig2_clean; left2; left2];
    
    % configurar filter bank (mesmas frequências que você usava)
    fb = cwtfilterbank('SignalLength', numel(sig2_ext), ...
                       'SamplingFrequency', fs, ...
                       'FrequencyLimits', [1e-7 1e-4]);
    
    % --- Calcular coerência wavelet (usando dt em segundos)
    dt = 300; % 5 min = 300 s
    [WCOH, ~, period, coi] = wcoherence(sig1_ext, sig2_ext, seconds(dt), 'FilterBank', fb);

    % Cortar parte central (dados originais)
    n = length(sig1_clean);
    try
        wcoh_central = WCOH(62:147, 2*n+1:3*n);
        coi_central  = coi(2*n+1:3*n);
        period_sel   = period(62:147,1);
    catch
        disp('Aviso: recorte 62:147 não disponível — usando todas as escalas.');
        wcoh_central = WCOH(:, 2*n+1:3*n);
        coi_central  = coi(2*n+1:3*n);
        period_sel   = period(:,1);
    end

    % Máscara de NaNs
    mask_nan = isnan(sig1) | isnan(sig2);
    wcoh_central(:, mask_nan) = NaN;

    % Converter período para dias
    period_days = days(period_sel);

    % Converter para log2 e inverter (eixo e matriz)
    period_log = log2(period_days);
    period_log_inv = flipud(period_log);
    wcoh_central = flipud(wcoh_central);

    % --- Plot ---
    figure('Name', ['WCOH: Ey × ' nome_vd], 'NumberTitle','off');
    h = pcolor(datenum(iono_time), period_log_inv, wcoh_central);
    set(h, 'EdgeColor', 'none', 'AlphaData', ~isnan(wcoh_central));
colormap jet;
c = colorbar;                  % salva o handle corretamente
c.Limits = [0 1];
c.Ticks = 0.1:0.1:0.9;
c.TickLabels = string(c.Ticks);

    set(gca, 'Color', 'w');

    ax = gca;
    ax.YDir = 'normal'; % garante que períodos menores fiquem embaixo

    % Escala do eixo X (dias)
    xticks_custom = datenum(datetime(2017,8,1):days(2):datetime(2017,8,31));
    ax.XTick = xticks_custom;
    ax.XTickLabel = datestr(xticks_custom, 'dd');
    ax.XTickLabelRotation = 90;

    % Escala do eixo Y (período em dias)
    periods2 = [0.25 0.5 1 2 4 8 16 31];
    yticks_log2 = log2(periods2);
    ax.YTick = yticks_log2;
    ax.YTickLabel = string(periods2);

    xlabel('Time (days)', 'FontSize', 16, 'FontWeight', 'bold');
    ylabel('Period (days)', 'FontSize', 16, 'FontWeight', 'bold');
    title(['Ey × ' nome_vd], ...
        'FontSize', 16, 'FontWeight', 'bold');

    % Ajustes gerais de fonte
    ax.FontSize = 16;          % tamanho dos ticks dos eixos
    c.Label.FontSize = 16;     % fonte da barra de cor
    c.FontSize = 16;           % ticks da barra de cor
    
    % Define os períodos desejados (em dias)
    periods2 = [0.25 0.5 1 2 4 8 16 31];

    % Converte para escala log2 (porque o eixo Y está em log2(period))
    yticks_log2 = log2(periods2);

    % Aplica os ticks e labels no eixo Y
    ax.YTick = yticks_log2;
    ax.YTickLabel = string(periods2);

    % Rotação dos rótulos do eixo X
    ax.XTickLabelRotation = 90;
    
    % Se quiser limitar X para o mês:
    xlim([datenum(datetime(2017,8,1)), datenum(datetime(2017,9,1))]);
    
    % exibir intervalo temporal para checagem
    disp(['Plot criado: Ey × ' nome_vd]);
    
    % --- Salvar figura automaticamente (simples)
    folder = 'images';
    if ~exist(folder, 'dir')
        mkdir(folder);
    end

    % criar nome de arquivo seguro (substituir {, }, espaço e / por _)
    nome_file = ['WCOH_Fejer_Ey_' nome_vd];
    nome_file = strrep(nome_file, '{','_');
    nome_file = strrep(nome_file, '}','_');
    nome_file = strrep(nome_file, ' ','_');
    nome_file = strrep(nome_file, '/','_');
    nome_file = strrep(nome_file, '\','_');

    filename = fullfile(folder, [nome_file '.png']);

    try
        saveas(gcf, filename);
        disp(['Figura salva em: ' filename]);
    catch ME
        warning('Não foi possível salvar a figura: %s', ME.message);
    end
end

disp('Terminado.');
