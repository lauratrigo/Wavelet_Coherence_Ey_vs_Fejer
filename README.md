# 🌠 Coerência Wavelet Ey (OMNI) × Vd / PPEF / DDEF – Agosto 2017

Este repositório contém scripts MATLAB para calcular a **Coerência Wavelet Contínua (WCOH)** entre o **campo elétrico Ey (OMNI)** e diferentes componentes do **drift ionosférico (Vd, PPEF e DDEF)** na estação **Araguatins (TO)** durante **agosto de 2017**.

O objetivo é investigar o acoplamento espectro-temporal entre o vento solar (Ey) e os drifts elétricos ionosféricos.

---

## 🛠 Tecnologias Usadas

- **MATLAB (R2019b ou superior)**
- **Wavelet Toolbox**
- Arquivos `.mat` com parâmetros ionosféricos (5 min)
- Arquivo `dados_Omni_Tratados.txt` com dados OMNI (5 min)
- Arquivo `drift.dat` com Vd, PPEF e DDEF (15 min)

![MATLAB Badge](https://img.shields.io/badge/MATLAB-R2019b-orange?logo=Mathworks&logoColor=white)

---

## 📊 Dados Utilizados

- **Parâmetros OMNI (5 min)**: `Ey (mV/m)`  
- **Parâmetros ionosféricos / drift (15 min)**: `Vd_mean`, `Vd_storm`, `Vd_total`, `PPEF`, `DDEF`

💡 Objetivo

- Aplicar análise de **coerência wavelet contínua (WCOH)** para identificar padrões espectro-temporais e períodos dominantes entre o **campo elétrico Ey** e os diferentes tipos de drifts elétricos na ionosfera durante **agosto de 2017**.

---

## 📂 Estrutura do Projeto

```bash
Wavelet_Coherence_Ey_vs_Fejer/
├── dados/
│   ├── mediasionosfericasARG.mat
│   ├── dados_Omni_Tratados.txt
│   └── drift.dat
├── images/
│   ├── WCOH_Ey_Vd_mean.png
│   ├── WCOH_Ey_Vd_storm.png
│   ├── WCOH_Ey_Vd_total.png
│   ├── WCOH_Ey_PPEF.png
│   └── WCOH_Ey_DDEF.png
├── wav_ey_vd.m
└── README.md
```

## ⚙️ Como Executar

1. Clone o repositório:

```bash
git clone https://github.com/lauratrigo/Wavelet_Coherence_Ey_vs_Fejer.git
cd Wavelet_Coherence_Ey_vs_Fejer
```

2. Abra o MATLAB e certifique-se de que os arquivos .mat, .txt e drift.dat estão na pasta dados/.

3. Execute o script principal:
4. 
```bash
run wav_ey_vd.m
```
Os gráficos serão salvos em images/.

---

## 📈 Gráficos Gerados

### Ey × Fejer 

#### Ey × Vd_mean
<div align="center">
  <img src="images/WCOH_Fejer_Ey_Vd__mean_.png">
</div>

#### Ey × Vd_storm
<div align="center">
  <img src="images/WCOH_Fejer_Ey_Vd__storm_.png">
</div>

#### Ey × Vd_total
<div align="center">
  <img src="images/WCOH_Fejer_Ey_Vd__total_.png">
</div>

#### Ey × PPEF
<div align="center">
  <img src="images/WCOH_Fejer_Ey_PPEF.png">
</div>

#### Ey × DDEF
<div align="center">
  <img src="images/WCOH_Fejer_Ey_DDEF.png">
</div>

## 🤝 Agradecimentos

Este projeto foi desenvolvido como parte de pesquisa em Física Espacial no IP&D/UNIVAP, com apoio do grupo de estudos em ionosfera e geomagnetismo.

## 📜 Licença

Este repositório está licenciado sob MIT License. Consulte o arquivo LICENSE para mais informações.

