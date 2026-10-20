# =============================================================================
# GUION DE CLASE — Semana 10 · Sesión 1: Lógica de Capas de ggplot2
# Fundamentos de Programación para Análisis Económico · UdeC-EAN
#
# Nombre: Camila Bravo Figueroa      Fecha: 20-10-2026
#
# CÓMO USAR: corre cada línea con Cmd/Ctrl+Enter.
#   🔵 CORRE Y OBSERVA · ✏️ COMPLETA (____) · 🔮 PREDICE · 🟢 TU TURNO · ✅ Deberías ver
#
# La Semana 9 nos enseñó a JUZGAR gráficos. Hoy empezamos a CONSTRUIRLOS.
# =============================================================================

library(dplyr)
library(tidyr)      # pivot_longer() (Semana 6)
library(ggplot2)
library(ggrepel)    # etiquetas que no se pisan (Bloque E)

casen <- read.csv("data/raw/casen_reducido.csv") |>
  mutate(experiencia = pmax(edad - educ - 6, 0))
salario <- read.csv("data/raw/salario_minimo_chile.csv")       # Semana 2
ene <- read.csv2("data/raw/ene-2026-06-mjj.csv")                # Semana 6 (2-3 s)

# 💡 EL MAPA DE LA GRAMÁTICA (slide 4). Todo gráfico se describe con:
#    datos · aesthetics · geometrías · stats · posiciones · escalas ·
#    coordenadas · facetas · temas. Hoy: los tres primeros + escalas.
#    La Sesión 2 completa el resto.


# -----------------------------------------------------------------------------
# BLOQUE A — Las tres capas mínimas
# -----------------------------------------------------------------------------
# Todo gráfico de ggplot2 necesita tres cosas:
#   1. DATOS   2. AESTHETICS (qué variable va a qué propiedad)   3. GEOM (la forma)

# 🔵 CORRE Y OBSERVA
ggplot(data = casen, aes(x = educ, y = ingreso)) +
  geom_point()

# ✅ Deberías ver: una nube de puntos ascendente, y un AVISO de que se
#    quitaron 5 filas. Ese aviso es correcto: son los 5 NA de ingreso.

# 🔮 PREDICE: ¿qué pasa si corro solo la primera parte, sin el geom?
ggplot(casen, aes(x = educ, y = ingreso))

# ✅ Deberías ver: los ejes dibujados pero NINGÚN punto.
# 💡 ggplot() solo prepara el lienzo. El geom es lo que dibuja.

# ⚠️ GOTCHA: las capas se unen con  +  , NO con  |>  .
#    El |> pasa datos al siguiente verbo (dplyr); el + agrega una capa (ggplot).
#    Sí se pueden combinar:  casen |> filter(...) |> ggplot(...) + geom_point()

## El gráfico es un OBJETO: guardarlo y sumarle capas
# 🔵 CORRE Y OBSERVA: al guardarlo con <- no se dibuja; al escribir su nombre, sí.
p <- ggplot(casen, aes(educ, ingreso)) +
  geom_point(color = "#223c6a")
p

# ✏️ COMPLETA: súmale la recta de regresión sin repetir lo anterior.
p + geom_smooth(method = "lm", se = FALSE, color = "#e69b0a")

# 🔮 PREDICE: después de la línea anterior, ¿p tiene la recta o no? Corre p. ____
p

# 💡 p + capa MUESTRA una versión nueva, pero p no cambia. Para guardarla:
#    p <- p + geom_smooth(...)   (sobrescribe)   ·   p2 <- p + ...   (otro objeto)


# -----------------------------------------------------------------------------
# BLOQUE B — Aesthetics: mapear vs fijar (el error #1)
# -----------------------------------------------------------------------------
# MAPEAR = el color depende de una VARIABLE -> DENTRO de aes()
# 🔵 CORRE Y OBSERVA
ggplot(casen, aes(x = educ, y = ingreso, color = genero)) +
  geom_point()

# ✅ Deberías ver: puntos en dos colores + una leyenda de género automática.

# FIJAR = el color es una decisión tuya -> FUERA de aes()
# 🔵 CORRE Y OBSERVA
ggplot(casen, aes(x = educ, y = ingreso)) +
  geom_point(color = "#223c6a", size = 3, alpha = 0.6)

# ✅ Deberías ver: todos los puntos azul institucional, SIN leyenda.

# 🔮 PREDICE antes de correr: ¿de qué color saldrán estos puntos?
#    Tu predicción: ____________
ggplot(casen, aes(x = educ, y = ingreso, color = "azul")) +
  geom_point()

# ✅ Deberías ver: ¡NO son azules! Son rojo-salmón, y hay una leyenda que
#    dice "azul".
#
# ⚠️ ESTE ES EL ERROR #1 DEL CURSO. Dentro de aes(), R cree que "azul" es una
#    VARIABLE nueva con un solo valor, y le asigna el primer color de la paleta.
#
#    LA REGLA: ¿depende de los datos? -> dentro de aes()
#              ¿es una decisión mía?  -> fuera de aes()

# ✏️ COMPLETA: mapea el tamaño a experiencia y el color a sector.
ggplot(casen, aes(x = educ, y = ingreso, size = experiencia, color = sector)) +
  geom_point(alpha = 0.7)

# 🔮 ¿Funciona? Sí. ¿Comunica bien? Mira el resultado y responde: ____
# 💡 Son 4 variables en un gráfico: funciona pero está sobrecargado (recap S9).
#    "Se puede" no es lo mismo que "se debe".

# 🔮 PREDICE: ¿qué pasa si mapeas la FORMA a una variable numérica (edad)?
#    try() muestra el error sin detener el script. ____
try(print(ggplot(casen, aes(educ, ingreso, shape = edad)) + geom_point()))

# 💡 La forma solo sirve para CATEGORÍAS: no existe "un triángulo y medio".
#    El color y el tamaño sí aceptan variables continuas (slide "Qué se puede mapear").

## La HERENCIA de aes(): global vs por capa
# Lo que va en ggplot(aes(...)) lo heredan TODAS las capas.
# Lo que va dentro de un geom_*() vale solo para esa capa.

# 🔮 PREDICE: ¿cuántas rectas de regresión dibuja este gráfico? ____
ggplot(casen, aes(educ, ingreso, color = genero)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE)

# ✏️ COMPLETA: ahora quiero los puntos por género pero UNA sola recta.
#    Mueve el color a la capa de puntos.
ggplot(casen, aes(educ, ingreso)) +
  geom_point(aes(color = genero)) +
  geom_smooth(method = "lm", se = FALSE, color = "black")

# ✅ Deberías ver: arriba DOS rectas (una por género, como la regresión por
#    grupo de la S8S2); abajo UNA recta para todos.


# -----------------------------------------------------------------------------
# BLOQUE C — Geoms básicos
# -----------------------------------------------------------------------------
## geom_point() + una línea de tendencia
# 🔵 CORRE Y OBSERVA
ggplot(casen, aes(educ, ingreso)) +
  geom_point() +
  geom_smooth(method = "lm", se = TRUE)

# ✅ Deberías ver: la nube + una recta ascendente con banda de confianza gris.

## geom_line(): series de tiempo
# El ingreso mínimo de la Semana 2. Dos series (nominal y real) en un gráfico
# necesitan los datos en formato LARGO (Semana 6).

# ✏️ COMPLETA: pasa a formato largo y dibuja una línea por serie.
salario |>
  mutate(Real = salario_minimo / ipc * 100) |>
  select(anio, Nominal = salario_minimo, Real) |>
  pivot_longer(-anio, names_to = "serie", values_to = "pesos") |>
  ggplot(aes(anio, pesos, color = serie)) +
  geom_line(linewidth = 1.2)

# ✅ Deberías ver: dos líneas. La nominal sube de 225.000 a 529.000; la real
#    (pesos de 2010) sube mucho menos, de ~198.000 a ~285.000.
#
# ⚠️ geom_line() une los puntos siguiendo el eje X. Si X fuera una categoría
#    sin orden natural (sector, región), la línea NO significaría nada.

## geom_col() vs geom_bar(): la confusión clásica
resumen <- casen |>
  group_by(sector) |>
  summarise(ing = mean(ingreso, na.rm = TRUE), .groups = "drop")

casen |> group_by(sector) |>
  summarise(ingreso = mean(ingreso, na.rm = TRUE)) |>
  ggplot(aes(reorder(sector, ingreso), ingreso)) + # reorder: ordenar (recap S9)
  geom_col(fill = "#223c6a") + coord_flip()

# ✏️ COMPLETA: geom_col() dibuja la altura que YO ya calculé.
ggplot(resumen, aes(x = reorder(sector, ing), y = sector)) +
  geom_col(fill = "#223c6a") +
  coord_flip()

# ✅ Deberías ver: 6 barras horizontales ORDENADAS de menor a mayor.

# 🔵 CORRE Y OBSERVA — geom_bar() en cambio CUENTA las filas
ggplot(casen, aes(x = sector)) +
  geom_bar(fill = "#e69b0a")

# ✅ Deberías ver: barras con el conteo de casos (Servicios es el más alto, 17).

# 💡 LA REGLA: ¿ya calculé el valor? -> geom_col()   ¿quiero que cuente? -> geom_bar()
#
# 💡 ¿Y reorder(sector, ing)? Ordena las barras por su valor. Sin él, ggplot
#    las ordena alfabéticamente, que casi nunca comunica mejor (recap S9).


# -----------------------------------------------------------------------------
# BLOQUE D — labs(): el texto que comunica
# -----------------------------------------------------------------------------
# 🟢 TU TURNO: completa las etiquetas. Fíjate bien en el título.
ggplot(casen, aes(educ, ingreso, color = genero)) +
  geom_point(alpha = 0.6) +
  geom_smooth(method = "lm", se = FALSE) +
  labs(
    title    = "A mayor educación, mayor ingreso",        # ¡el HALLAZGO, no las variables!
    subtitle = "Trabajadores ocupados · muestra reducida CASEN",
    x        = "Años de escolaridad",
    y        = "Ingreso mensual ($)",           # no olvides la unidad ($)
    color    = "Género",
    caption  = "Fuente: elaboración propia"           # la fuente SIEMPRE
  ) +
  scale_y_continuous(labels = scales::label_number(big.mark = ".", decimal.mark = ",")) +
  theme_minimal()

# 💡 EL TÍTULO DICE EL HALLAZGO:
#    ❌ "Ingreso vs educación"        -> describe los ejes, que ya se ven
#    ✅ "A más educación, mayor ingreso — y la brecha de género persiste"
#    Es el cambio que más rápido mejora un gráfico.
#
# 💡 scales::label_number(big.mark = ".", decimal.mark = ",") escribe 850.000
#    en vez de "8.5e+05": miles con punto, decimales con coma, como en Chile.
#    El paquete scales (pesos, miles, millones, %) se ve completo en la S10S2.

# ✏️ COMPLETA: guarda la figura en disco (nunca con captura de pantalla).
dir.create("output/figuras", recursive = TRUE, showWarnings = FALSE)   # crea la carpeta si no existe
ggsave("output/figuras/mi_grafico.png", width = 8, height = 5, dpi = 300)
#� dir.create() evita el error "cannot open file" si la carpeta no existe.
# 💡 dpi = 300 es calidad de impresión, y es lo que exigirá la T4.


# -----------------------------------------------------------------------------
# BLOQUE E — El rediseño de la Semana 9, en código (ENE)
# -----------------------------------------------------------------------------
regiones <- c("Tarapacá", "Antofagasta", "Atacama", "Coquimbo", "Valparaíso",
              "O'Higgins", "Maule", "Biobío", "La Araucanía", "Los Lagos",
              "Aysén", "Magallanes", "Metropolitana", "Los Ríos",
              "Arica y Parinacota", "Ñuble")

# ✏️ COMPLETA: informalidad PONDERADA por región, total y por sexo (S6 y S7).
inf_region <- ene |>
  filter(activ == 1) |>                                    # ocupados
  mutate(informal   = ocup_form == 2,                   # 2 = informal
         mujer      = sexo == 2,
         region_txt = regiones[region]) |>
  group_by(region_txt) |>
  summarise(total   = 100 * weighted.mean(informal, fact_cal),
            hombres = 100 * weighted.mean(informal[!mujer], fact_cal[!mujer]),
            mujeres = 100 * weighted.mean(informal[mujer],  fact_cal[mujer]))
inf_nacional <- 26.5                                       # % de Chile, ponderado

head(arrange(inf_region, desc(total)), 3)

# ✅ Deberías ver: La Araucanía 35,0 · Ñuble 34,5 · Los Ríos 33,2

## Paso 1 · Resaltar un grupo: una columna lógica mapeada a fill
# ✏️ COMPLETA: destaca Ñuble en dorado; el resto en gris.
p1 <- inf_region |>
  mutate(destacar = region_txt == "Ñuble") |>
  ggplot(aes(total, reorder(region_txt, total), fill = destacar)) +
  geom_col() +
  scale_fill_manual(values = c(`TRUE` = "#e69b0a", `FALSE` = "grey75"),
                    guide = "none") +
  labs(x = "% de ocupados informales", y = NULL)
p1

## Paso 2 · Valores escritos y una línea de referencia
# ✏️ COMPLETA: escribe cada valor y marca el promedio nacional.
p1 +
  geom_text(aes(label = round(total, 1)), hjust = -0.15, size = 3.3) +
  geom_vline(xintercept = inf_nacional, linetype = "dashed") +
  annotate("text", x = inf_nacional + 0.5, y = 2, hjust = 0,
           label = "Promedio de Chile: 26,5 %") +
  scale_x_continuous(limits = c(0, 40))

# 💡 geom_text() es una CAPA con su propio aes(label = ). geom_vline() traza
#    una referencia. annotate() escribe UN texto fijo, sin mapear variables.

## Paso 3 · Etiquetar puntos sin que se pisen (ggrepel)
# 🔮 PREDICE: si uso geom_text() con 16 nombres de región, ¿qué pasará? ____
# ✏️ COMPLETA: usa la versión de ggrepel.
ggplot(inf_region, aes(hombres, mujeres)) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "grey50") +
  geom_point(color = "#223c6a", size = 2.5) +
  geom_text_repel(aes(label = region_txt), size = 3, max.overlaps = Inf, seed = 1) +
  labs(x = "Informalidad hombres (%)", y = "Informalidad mujeres (%)")

# ✅ Deberías ver: 16 puntos con su nombre, sin superponerse. Sobre la
#    diagonal, las mujeres son más informales (Tarapacá, Atacama); cerca de
#    ella, sin brecha (Ñuble, La Araucanía).

# 🟢 TU TURNO: en el Paso 1, destaca TU región (o la de tu familia) en vez de
#    Ñuble y cambia el título con labs(title = ) para que diga el hallazgo.

p1 <- inf_region |>
  mutate(destacar = region_txt == "Metropolitana") |>
  ggplot(aes(total, reorder(region_txt, total), fill = destacar)) +
  geom_col() +
  scale_fill_manual(values = c(`TRUE` = "#e69b0a", `FALSE` = "grey75"),
                    guide = "none") +
  labs(title = "Informalidad laboral en la capital", x = "% de ocupados informales", y = NULL)
p1

# -----------------------------------------------------------------------------
# CIERRE — datos + aes() + geom = gráfico. Las capas se suman con + .
#          Mapear (dentro de aes) vs fijar (fuera de aes).
#          El título comunica el hallazgo. aes() global se hereda.
#          geom_text, geom_vline, annotate y ggrepel = etiquetar y referenciar.
# Puente Sesión 2: stats, posiciones, coordenadas, paletas, temas y facetas.
#   Y arranca la T4 (calificada).
# =============================================================================
