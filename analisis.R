library(tidyverse)

# Crear el directorio de salida si no existe
dir.create("output", showWarnings = FALSE)

# 1. Cargamos los datos del INE
# -----------------------------
paro_raw <- read_csv2("data/tasa_paro.csv")
empleo_raw <- read_csv2("data/tasa_empleo.csv")
natalidad_raw <- read_csv2("data/tasa_natalidad.csv")

# 2. Limpieza Datos Tasa Natalidad
# --------------------------------

natalidad_clean <- natalidad_raw |>
  # Renombramos las columnas
  rename(
    ccaa = "Comunidades y Ciudades Autónomas",
    nacionalidad = "Nacionalidad",
    anio = "Periodo",
    tasa_natalidad = "Total"
  ) |>
  # Filtramos todos los datos
  filter(
    nacionalidad == "Ambas nacionalidades",
    !str_detect(ccaa, "Total Nacional")
  ) |>
  # Aseguramos que  valor y anio sean numeros
  mutate(
    anio = as.numeric(anio),
    tasa_natalidad = as.numeric(str_replace(str_trim(tasa_natalidad), ",", "."))
  ) |>
  # Eliminamos la columna nacionalidad
  select(-nacionalidad)

# 3. Modelo 1: Paro Femenino VS Natalidad
# ---------------------------------------

# Limpiamos la tabla de tasa de paro

# La tasa de paro es trimestral hasta 2025, 
# mientras que la de natalidad es anual hasta 2024.

# Pasamos el periodo de tasa de paro a año y eliminamos el dato de 2025
# Tambien tenemos que filtrar la edad (Total) y el sexo (Mujeres)
paro_clean <- paro_raw |>
  # Renombramos las columnas
  rename(
    sexo = "Sexo",
    ccaa = "Comunidades y Ciudades Autónomas",
    edad = "Edad",
    periodo = "Periodo",
    valor = "Total"
  ) |>
  filter(
    sexo == "Mujeres",
    edad == "Total",
    !str_detect(ccaa, "Total Nacional")
  ) |>
  # Obtener el valor anual:
  # Convertir valor a numero para que no salga NaN
  mutate(
    valor = str_trim(valor), # Quitamos los espacios en blanco
    valor = str_replace(valor, ",", "."), # Cambiamos la coma por el punto
    valor = as.numeric(valor) # Convertimos a numero
  ) |>
  # Extraemos los primeros 4 caracteres del texto
  mutate(anio = as.numeric(substr(periodo, 1,4))) |>
  # Agrupamos por año y comunidad autonoma
  group_by(anio, ccaa) |>
  # Calculamos la media de los 4 trimestres
  summarise(tasa_paro = mean(valor, na.rm = TRUE)) |>
  ungroup()  |>
  # Nos quedamos con los datos que tienen pareja en natalidad
  filter(anio <= 2024)


# Unión de tablas (JOIN)
tabla_maestra_paro <-
  inner_join(paro_clean, natalidad_clean, by = c("anio", "ccaa"))

# Visualización Diagnóstica Drill-Down
# Gráfico de dispersión con línea de regresión
ggplot(tabla_maestra_paro, aes(x = tasa_paro, y = tasa_natalidad)) +
  geom_point(alpha = 0.5, color = "steelblue") + # Los puntos (Los años)
  geom_smooth(method = "lm", color = "red") + # La línea de tendencia
  facet_wrap(~ccaa) + # DRILL-DOWN: Un gráfico por CCAA
  labs(
    title = "Relación entre Tasa de Paro Femenino y Natalidad",
    subtitle = "Análisis por Comunidad Autónoma (2002-2024)",
    x = "Tasa de Paro (%)",
    y = "Tasa de Natalidad (Nacimientos por 1.000 hab.)"
  ) +
  theme_minimal()

ggsave(
  "output/relacion_paro_femenino_y_natalidad.png",
  width = 10,
  height = 6,
  bg = "white"
)

correlacion_modelo1 <-
  cor(
    tabla_maestra_paro$tasa_paro, tabla_maestra_paro$tasa_natalidad,
    use = "complete.obs"
  )

print(
  paste(
    "La correlación de Pearson para el Modelo 1 
    (Tasa Paro y Tasa Natalidad) es:",
    round(correlacion_modelo1, 4)
  )
)

#  Modelo de Regresión Lineal (lm)
modelo1 <- lm(tasa_natalidad ~ tasa_paro, data = tabla_maestra_paro)

#  Ver el resumen del modelo
summary(modelo1)


# 4. Modelo 2: Empleo Femenino VS Natalidad
# ----------------------------------------

# Limpiamos la tabla de tasa de empleo
empleo_mujeres_clean <- empleo_raw |>
  # Renombramos las columnas
  rename(sexo = "Sexo", ccaa = "Comunidades y Ciudades Autónomas",
         edad = "Edad", anio = "Periodo", tasa_empleo = "Total") |>
  # Filtramos por Mujeres y Edad Total
  filter(
    sexo == "Mujeres",
    edad == "Total",
    !str_detect(ccaa, "Total Nacional")
  ) |>
  # Verificamos que los valores sean numéricos
  mutate(
    anio = as.numeric(anio),
    tasa_empleo = as.numeric(str_replace(str_trim(tasa_empleo), ",", "."))
  ) |>
  # Eliminamos las columnas no necesarias
  select(-sexo, -edad)

# JOIN de las tablas
tabla_maestra_mujeres <-
  inner_join(empleo_mujeres_clean, natalidad_clean, by = c("anio", "ccaa"))

# Creación Gráfico y Modelo 2 (mismo procedimiento)
ggplot(tabla_maestra_mujeres, aes(x = tasa_empleo, y = tasa_natalidad)) +
  geom_point(alpha = 0.5, color = "hotpink") + 
  geom_smooth(method = "lm", color = "darkblue") +
  facet_wrap(~ccaa) +
  labs(title = "Relación entre Tasa de Empleo Femenino y Natalidad",
       subtitle = "Análisis por Comunidad Autónoma (2006-2024)",
       x = "Tasa de Empleo Femenino (%)",
       y = "Tasa de Natalidad (Nacimientos por 1.000 hab.)") +
  theme_minimal()

ggsave(
  "output/relacion_empleo_femenino_y_natalidad.png",
  width = 10, height = 6, bg = "white"
)

correlacion_modelo2 <-
  cor(
    tabla_maestra_mujeres$tasa_empleo, tabla_maestra_mujeres$tasa_natalidad,
    use = "complete.obs"
  )

print(
  paste(
    "La correlación de Pearson para el Modelo 2 
    (Tasa Empleo Femenino y Tasa Natalidad) es:",
    round(correlacion_modelo2, 4)
  )
)

#  Modelo de Regresión Lineal (lm)
modelo2 <- lm(tasa_natalidad ~ tasa_empleo, data = tabla_maestra_mujeres)

#  Ver el resumen del modelo
summary(modelo2)


# 5. Modelo 3: Empleo Masculino VS Natalidad
# ----------------------------------------

# Limpiamos la tabla de tasa de empleo
empleo_hombres_clean <- empleo_raw |>
  # Renombramos las columnas
  rename(sexo = "Sexo", ccaa = "Comunidades y Ciudades Autónomas",
         edad = "Edad", anio = "Periodo", tasa_empleo = "Total") |>
  # Filtramos por Hombres y Edad Total
  filter(
    sexo == "Hombres", edad == "Total", !str_detect(ccaa, "Total Nacional")
  ) |>
  # Verificamos que los valores sean numéricos
  mutate(
    anio = as.numeric(anio),
    tasa_empleo = as.numeric(str_replace(str_trim(tasa_empleo), ",", "."))
  ) |>
  # Eliminamos las columnas no necesarias
  select(-sexo, -edad)

# JOIN de las tablas
tabla_maestra_hombres <-
  inner_join(empleo_hombres_clean, natalidad_clean, by = c("anio", "ccaa"))

# Creación Gráfico y Modelo 3 (mismo procedimiento)
ggplot(tabla_maestra_hombres, aes(x = tasa_empleo, y = tasa_natalidad)) +
  geom_point(alpha = 0.5, color = "darkgreen") + 
  geom_smooth(method = "lm", color = "red") +
  facet_wrap(~ccaa) +
  labs(title = "Relación entre Tasa de Empleo Masculino y Natalidad",
       subtitle = "Análisis por Comunidad Autónoma (2006-2024)",
       x = "Tasa de Empleo Masculino (%)",
       y = "Tasa de Natalidad (Nacimientos por 1.000 hab.)") +
  theme_minimal()

ggsave(
  "output/relacion_empleo_masculino_y_natalidad.png",
  width = 10, height = 6, bg = "white"
)

correlacion_modelo3 <-
  cor(
    tabla_maestra_hombres$tasa_empleo, tabla_maestra_hombres$tasa_natalidad,
    use = "complete.obs"
  )
print(
  paste(
    "La correlación de Pearson para el Modelo 3 
    (Tasa Empleo Masculino y Tasa Natalidad) es:",
    round(correlacion_modelo3, 4)
  )
)

#  Modelo de Regresión Lineal (lm)
modelo3 <- lm(tasa_natalidad ~ tasa_empleo, data = tabla_maestra_hombres)

#  Ver el resumen del modelo
summary(modelo3)
