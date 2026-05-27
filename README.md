# Análisis Diagnóstico: Impacto del Mercado Laboral en la Natalidad

Este repositorio contiene un análisis estadístico desarrollado en **R** que explora la relación directa entre la situación laboral y el descenso demográfico en España. Utilizando datos oficiales, el proyecto implementa limpieza de datos relacionales, visualización diagnóstica (*Drill-Down*) y modelos de regresión lineal simple.  

📄 **[Leer el Informe de Análisis Diagnóstico (PDF)](./docs/Análisis_Diagnóstico.pdf)**

---

## Metodología y Procesamiento de Datos (ETL)

El script principal (`analisis.R`) utiliza el ecosistema `tidyverse` para estructurar y modelar la información bruta:

- **Fuentes de Datos**: Se han seleccionado datos oficiales del INE (Instituto Nacional de Estadística).

- **Variable Dependiente (Y)**: Tasa de Natalidad (nacimientos por cada 1.000 habitantes).

- **Variables Independientes (X)**: Tasa de Empleo Femenino, Tasa de Empleo Masculino y Tasa de Paro Femenino.

- **Alcance Analítico**: El estudio se ha realizado a nivel de Comunidad Autónoma, permitiendo un análisis *Drill-Down* regional.  

- **Profundidad Temporal**: Se ha analizado una serie temporal de 22 años para la tasa de paro y 19 años para la tasa de empleo (2006-2024).

---

## Conclusiones del Modelado Estadístico

Tras el cruce de tablas (`inner_join`) y el cálculo de la correlación de Pearson, se entrenaron tres modelos de regresión lineal simple (`lm`), arrojando las siguientes conclusiones:

- El modelo de empleo femenino arrojó un $R^2$ de 0.1229, explicando el 12,3% de la variabilidad de la natalidad.  

- Se determinó que la relación es negativa y estadísticamente significativa ($p < 0.05$): a mayor inserción laboral femenina, menor natalidad.  

- El análisis del paro femenino confirma esta tendencia mediante una correlación inversa, mostrando que las regiones con mayor desempleo femenino tienden a mantener tasas de natalidad levemente superiores.  

- Existe una clara asimetría de género en el impacto laboral: el modelo de empleo masculino muestra una relación positiva ($R^2 = 0.055$), sugiriendo que actúa como factor de estabilidad favorable para la paternidad.  

- Los bajos valores de $R^2$ (entre 0.05 y 0.12) demuestran que el mercado laboral influye, pero no es la única causa.  Esto sugiere la necesidad de investigar otras variables estructurales no incluidas en este modelo, como el coste de la vivienda o la edad de emancipación, para explicar el 88% restante de la variabilidad del descenso demográfico en España.  

---

## Arquitectura del Proyecto

```text
analisis-natalidad-empleo-espana/
├── data/                                # Datasets brutos extraídos del INE (CSV)
│   ├── tasa_empleo.csv
│   ├── tasa_natalidad.csv
│   └── tasa_paro.csv
├── docs/                                # Informe PDF con el análisis y las conclusiones
├── output/                              # Gráficos generados automáticamente por el script
│   ├── relacion_empleo_femenino_y...
│   ├── relacion_empleo_masculino_y...
│   └── relacion_paro_femenino_y...
└── analisis.R                           # Script principal con la lógica de limpieza y modelado
```

---

## Instalación y Ejecución

Para reproducir este análisis en tu máquina local, necesitas tener instalado **R** y, opcionalmente, un entorno como RStudio.

1. Clona el repositorio:

    ```bash
    git clone https://github.com/paulaschez/analisis-natalidad-empleo-espana
    cd analisis-natalidad-empleo-espana
    ```

2. Instala el paquete `tidyverse` en la consola de R (si no lo tienes ya):

   ```R
    install.packages("tidyverse")
   ```

3. Ejecuta el script `analisis.R`. El código leerá los archivos de la carpeta `data/`, imprimirá por consola los resúmenes estadísticos (`summary`) de los modelos y exportará los gráficos generados directamente a la carpeta `output/`.

---
**Autora:** Paula Sánchez Vélez · [@paulaschez](https://github.com/paulaschez)