# =============================================================================
# GUION DE CLASE — Semana 10 · Sesión 2: Personalización y Temas
# Fundamentos de Programación para Análisis Económico · UdeC-EAN
#
# Nombre: Camila Bravo Figueroa      Fecha: 20-10-2026
#
# CÓMO USAR: corre cada línea con Cmd/Ctrl+Enter y mira el panel Plots.
#   🔵 CORRE Y OBSERVA · ✏️ COMPLETA (____) · 🔮 PREDICE · 🟢 TU TURNO
#   ✅ Deberías ver
#
# La Sesión 1 armó gráficos con datos + aes + geom. Hoy completamos el mapa de
# la gramática: ESCALAS (y el paquete scales), STATS, POSICIONES, COORDENADAS,
# FACETAS y TEMAS.
# =============================================================================


# -----------------------------------------------------------------------------
# 📦 PAQUETES DE HOY
# -----------------------------------------------------------------------------
# Si es la primera vez que los usas:
# install.packages(c("patchwork", "scales"))
#
#   dplyr      organizar los datos antes de graficar (Semanas 5-7).
#   ggplot2    los gráficos. Trae viridis y ColorBrewer incluidos.
#   scales     formatea los números de los ejes: pesos, miles, millones, %.
#              Viene instalado con ggplot2. Funciones label_*():
#              label_currency(), label_number(), label_percent().
#              Referencia: https://scales.r-lib.org/reference/
#   patchwork  pone gráficos lado a lado con  p1 + p2  (Semana 11).
#
# Temas listos para usar (solo como referencia, no hace falta instalarlos hoy):
#   https://ggplot2.tidyverse.org/reference/ggtheme.html   (los de ggplot2)
#   https://jrnold.github.io/ggthemes/                     (paquete ggthemes)

library(dplyr)
library(ggplot2)
library(scales)
library(patchwork)

azul <- "#223c6a"; oro <- "#e69b0a"

casen   <- read.csv("data/raw/casen_reducido.csv")
salario <- read.csv("data/raw/salario_minimo_chile.csv")
ene     <- read.csv2("data/raw/ene-2026-06-mjj.csv")         # 2-3 segundos


# -----------------------------------------------------------------------------
# BLOQUE A — Escalas: scale_<estética>_<tipo>
# -----------------------------------------------------------------------------
# aes() dice QUÉ variable va a una propiedad visual; la ESCALA dice CÓMO.
# Cuatro argumentos sirven en casi todas: name, limits, breaks, labels.

# 🔵 CORRE Y OBSERVA: el gráfico sin escalas propias
ggplot(casen, aes(educ, ingreso)) + geom_point(color = azul)

# 🔮 PREDICE: ¿qué escribe R en el eje Y? ¿Lo entendería alguien en un informe? ____

# ✏️ COMPLETA: eje X con marcas cada 2 años; eje Y desde 0.
ggplot(casen, aes(educ, ingreso)) +
  geom_point(color = azul) +
  scale_x_continuous(name = "Años de educación", breaks = seq(6, 20, 2)) +
  scale_y_continuous(name = "Ingreso mensual", limits = c(0, 1200000))

## El paquete scales: los label_*() fabrican un FORMATEADOR -----------------
# Un formateador es una FUNCIÓN: recibe números y devuelve texto.
pesos <- c(529000, 1250000, 9314017)

# 🔵 CORRE Y OBSERVA
label_currency(big.mark = ".", decimal.mark = ",")(pesos)     # Pesos chilenos

# ✅ Deberías ver: "$529.000" "$1.250.000" "$9.314.017"

# ✏️ COMPLETA: los mismos números en miles ("529 mil").
label_number(scale = 0.001, suffix = " mil", big.mark = ".", decimal.mark = ",")(pesos)

# 🔵 CORRE Y OBSERVA: mil y millones automáticos
label_number(scale_cut = c(0, " mil" = 1e3, " MM" = 1e6),
             big.mark = ".", decimal.mark = ",", accuracy = 0.1)(pesos)

# ✅ Deberías ver: "529,0 mil" "1,2 MM" "9,3 MM"

# ✏️ COMPLETA: dólares y porcentajes.
label_currency(prefix = "US$")(c(560, 1200))
label_percent(accuracy = 0.1, decimal.mark = ",", suffix = " %")(c(0.265, 0.345))

# ✅ Deberías ver: "US$ 560" "US$ 1,200" · "26,5 %" "34,5 %"

# 🔮 PREDICE: ¿qué pasa si escribes label_number(big.mark = ".") sin
#    decimal.mark? Pruébalo. ____
label_number(big.mark = ".")(1234.5)

# 💡 big.mark (miles) y decimal.mark (decimales) se cambian SIEMPRE juntos.
#    En código antiguo verás label_dollar(): es el nombre anterior de
#    label_currency().

## El formateador va en el argumento labels de la escala del eje ------------
# ✏️ COMPLETA: el ingreso mínimo con el eje Y en pesos chilenos.
ggplot(salario, aes(anio, salario_minimo)) +
  geom_line(color = azul, linewidth = 1.2) +
  scale_y_continuous(labels = label_currency(big.mark = ".", decimal.mark = ","),
                     limits = c(0, NA)) +
  labs(x = NULL, y = NULL, title = "Ingreso mínimo mensual")

# 💡 limits = c(0, NA): el mínimo fijo en 0, el máximo lo decide R.

# 🟢 TU TURNO: el scatter de CASEN (educ vs ingreso) con el eje Y en MILES
#    ("400 mil", "800 mil"...). Usa label_number() con scale y suffix.



## Color mapeado: _d (discreto) o _c (continuo) --------------------------------
# 🔵 CORRE Y OBSERVA: color según una CATEGORÍA (sector) -> escala discreta
ggplot(casen, aes(educ, ingreso, color = sector)) +
  geom_point(size = 2) +
  scale_color_viridis_d()

# ✏️ COMPLETA: color según una MAGNITUD (edad) -> escala continua.
ggplot(casen, aes(educ, ingreso, color = edad)) +
  geom_point(size = 2) +
  scale_color_viridis_c()                                    # pista: scale_color_viridis_?()

# Colores propios: la paleta del curso
ggplot(casen, aes(educ, ingreso,
                  color = genero)) +
  geom_point(size = 2) +
  scale_color_manual(
    values = c("M"=azul, "F"=oro))

# 🔮 PREDICE: ¿qué pasa si usas scale_color_viridis_d() con edad? ____

# 💡 _d = discrete (categorías), _c = continuous (magnitudes). Para fijar colores
#    a mano: scale_color_manual(values = c(F = "#e69b0a", M = "#223c6a")).

## Paletas en código (Semana 9) -------------------------------------------------
ocupados <- ene |>
  filter(activ == 1) |>
  mutate(sexo = ifelse(sexo == 1, "Hombre", "Mujer"),
         categoria = case_when(categoria_ocupacion == 3 ~ "Asal. privado",
                               categoria_ocupacion == 4 ~ "Asal. público",
                               categoria_ocupacion == 2 ~ "Cuenta propia",
                               TRUE                     ~ "Otras"))

base <- ggplot(ocupados, aes(y = categoria, fill = categoria, weight = fact_cal)) +
  geom_bar(show.legend = FALSE) + labs(x = NULL, y = NULL)

# ✏️ COMPLETA: tres formas de elegir los colores.
base + scale_fill_brewer(palette = "Set2")
base + scale_fill_manual(values = unname(palette.colors(5, "Okabe-Ito"))[-1])
base + scale_fill_viridis_d()

base <- ggplot(ocupados, aes(y = categoria, fill = categoria, weight = fact_cal)) +
  geom_bar(show.legend = FALSE) + # el eje ya nombra cada barra
  labs(x = NULL, y = NULL) + scale_x_continuous(labels = NULL)
(base + scale_fill_brewer(palette = "Set2") + labs(title = "scale_fill_brewer()")) +
  (base + scale_fill_manual(values = unname(palette.colors(5, "Okabe-Ito"))[-1]) +
     labs(title = "scale_fill_manual() + Okabe-Ito")) +
  (base + scale_fill_viridis_d() + labs(title = "scale_fill_viridis_d()"))

# -----------------------------------------------------------------------------
# BLOQUE B — Stats, posiciones y coordenadas
# -----------------------------------------------------------------------------
## Stats: geom_bar() CUENTA filas ----------------------------------------------
# 🔵 CORRE Y OBSERVA: cuenta personas ENCUESTADAS (la muestra)
ggplot(ocupados, aes(y = categoria)) + geom_bar()
nrow(ocupados)

# ✏️ COMPLETA: con weight, el stat SUMA los pesos (la población, Semana 6).
ggplot(ocupados, aes(y = categoria, weight = fact_cal)) + geom_bar(fill = azul)
sum(ocupados$fact_cal)

# ✅ Deberías ver: 41.850 encuestados que representan 9.314.017 ocupados.

## Posiciones: stack, dodge, fill ---------------------------------------------
base2 <- ggplot(ocupados, aes(sexo, fill = categoria, weight = fact_cal)) +
  scale_fill_brewer(palette = "Set2") + labs(x = NULL, y = NULL, fill = NULL)

base2 + geom_bar(position = "stack")       # totales
base2 + geom_bar(position = "dodge")       # lado a lado
# ✏️ COMPLETA: cada barra suma 100 % (el prop.table(margin = 1) de la Semana 7).
base2 + geom_bar(position = "fill") + scale_y_continuous(labels = label_percent())


# 🔵 CORRE Y OBSERVA: las proporciones que dibuja "fill"
ocupados |>
  group_by(sexo, categoria) |>
  summarise(pob = sum(fact_cal), .groups = "drop") |>
  group_by(sexo) |>
  mutate(pct = round(100 * pob / sum(pob), 1))

# ✅ Deberías ver: cuenta propia 21,1 % (hombres) y 21,2 % (mujeres): igual.
#    Asalariado público 9,2 % contra 17,0 %: ahí está la diferencia.

## Coordenadas: zoom no es lo mismo que cortar --------------------------------
g <- ggplot(casen, aes(educ, ingreso)) +
  geom_point(color = "grey60") +
  geom_smooth(method = "lm", se = FALSE, color = oro)

# 🔮 PREDICE: ¿la recta será la misma en los dos gráficos? ____
g + ylim(400000, 800000)                          # escala: BORRA lo de afuera
g + coord_cartesian(ylim = c(400000, 800000))     # coordenada: solo acerca

# 🔵 CORRE Y OBSERVA: la cuenta que hace ylim() a escondidas
coef(lm(ingreso ~ educ, data = casen))
coef(lm(ingreso ~ educ, data = filter(casen, ingreso >= 400000, ingreso <= 800000)))

# ✅ Deberías ver: pendiente 42.080 con todos; 12.438 con las 31 personas que
#    quedan dentro del rango. Para hacer zoom, siempre coord_cartesian().


# -----------------------------------------------------------------------------
# BLOQUE C — Facetas: un panel por grupo
# -----------------------------------------------------------------------------
# ✏️ COMPLETA: horas promedio (ponderadas, sin centinelas) por tramo de 5 años
#    de edad y categoría ocupacional.
horas_edad <- ene |>
  filter(activ == 1, edad <= 75) |>
  mutate(horas = na_if(na_if(habituales, 888), 999),
         categoria = case_when(categoria_ocupacion == 3      ~ "Asalariado privado",
                               categoria_ocupacion == 4      ~ "Asalariado público",
                               categoria_ocupacion == 2      ~ "Cuenta propia",
                               categoria_ocupacion == 1      ~ "Empleador",
                               categoria_ocupacion %in% 5:6  ~ "Servicio doméstico",
                               TRUE                          ~ "Familiar no remunerado"),
         edad = pmin(floor(edad / 5) * 5, 70) + 2.5) |>      # punto medio del tramo
  group_by(categoria, edad) |>
  summarise(horas = weighted.mean(horas, fact_cal, na.rm = TRUE),
            n = n(), .groups = "drop") |>
  filter(n >= 10)

# 🔵 CORRE Y OBSERVA: el problema, seis líneas de colores que se cruzan
ggplot(horas_edad, aes(edad, horas, color = categoria)) +
  geom_line()

# ✏️ COMPLETA: un panel por categoría, en 3 columnas.
ggplot(horas_edad, aes(edad, horas)) +
  geom_line(color = azul) +
  facet_wrap(~ categoria, ncol =3)

# ✏️ COMPLETA: cada panel con su propio eje Y.
ggplot(horas_edad, aes(edad, horas)) +
  geom_line(color = azul) +
  facet_wrap(~ categoria, ncol = 3, scales = "free_y")


ggplot(horas_edad, aes(edad, horas)) +
geom_line(color = azul, linewidth = 0.8) +
facet_wrap(~ categoria, ncol = 3, scales = "free_y") + # cada panel, su eje Y
labs(x = "Edad", y = "Horas habituales por semana")


# 🔮 PREDICE: con ejes libres, ¿puedes decir qué categoría trabaja MÁS horas
#    mirando la altura de las líneas? ____

# 🔵 CORRE Y OBSERVA: facet_grid() cruza DOS variables (filas ~ columnas)
ggplot(casen, aes(educ, ingreso)) +
  geom_point(color = azul) +
  facet_grid(genero ~ region)

# 🟢 TU TURNO: un panel por SEXO con la informalidad (%) por tramo de edad de
#    la ENE. Pista: agrupa por sexo y edad (en tramos), calcula
#    weighted.mean(ocup_form == 2, fact_cal), y usa facet_wrap(~ sexo).



# -----------------------------------------------------------------------------
# BLOQUE D — Temas: todo lo que NO es dato
# -----------------------------------------------------------------------------
p <- ggplot(horas_edad, aes(edad, horas)) +
  geom_line(color = azul) +
  facet_wrap(~ categoria, ncol = 3) +
  labs(title = "Horas por edad y categoría", x = "Edad", y = "Horas por semana")

# 🔵 CORRE Y OBSERVA: tres temas completos
p + theme_gray()       # el de ggplot2 por defecto
p + theme_minimal()
p + theme_bw()

# theme() cambia elementos sueltos. Cada elemento lleva una función element_*():
#   element_text()  textos       (plot.title, axis.text, strip.text)
#   element_line()  líneas       (panel.grid.major, axis.line)
#   element_rect()  fondos       (panel.background, strip.background)
#   element_blank() BORRAR el elemento
# ✏️ COMPLETA
p + theme_minimal() +
  theme(plot.title       = element_text(face = "bold", color = azul),
        strip.text       = element_text(face = "bold", hjust = 0),
        strip.background = element_rect(fill = "grey92", color = NA),
        panel.grid.minor = element_line())

# 💡 Lista completa de elementos: ?theme

## Un tema reutilizable: se guarda en un objeto -------------------------------
tema_curso <- theme_minimal(base_size = 13) +
  theme(plot.title = element_text(face = "bold", color = azul),
        legend.position = "bottom")

ggplot(casen, aes(educ, ingreso, color = genero)) +
  geom_point(size = 2) +
  scale_color_manual(values = c(F = oro, M = azul)) +
  scale_y_continuous(labels = label_number(scale = 1e-3, suffix = " mil",
                                           big.mark = ".", decimal.mark = ",")) +
  labs(title = "A más educación, más ingreso", x = "Años de educación",
       y = NULL, color = NULL) +
  tema_curso

# 🟢 TU TURNO: cambia legend.position a "none" y agrega etiquetas directas,
#    o prueba un tema de https://jrnold.github.io/ggthemes/ (requiere instalar
#    el paquete ggthemes).



# -----------------------------------------------------------------------------
# BLOQUE F — Exportar
# -----------------------------------------------------------------------------
dir.create("output/figuras", recursive = TRUE, showWarnings = FALSE)
# ✏️ COMPLETA: 300 dpi, el estándar de impresión (lo pide la T4).
ggsave("output/figuras/s10s2_horas_categoria.png", p + theme_minimal(),
       width = 10, height = 6, dpi = 300)

# ✅ Deberías ver: el archivo en output/figuras/. ggsave() guarda el gráfico
#    que le pases (o el último que se dibujó, si no le pasas ninguno).


# -----------------------------------------------------------------------------
# CIERRE — scale_<estética>_<tipo> + scales::label_*() para ejes legibles ·
#          paletas accesibles · weight = fact_cal · stack/dodge/fill ·
#          coord_cartesian() para hacer zoom · facet_wrap()/facet_grid() con
#          ncol y scales = "free_y" · theme() + element_*() · ggsave(dpi = 300).
# Al laboratorio (2 h): primero el gráfico horrible y su redención
#   (labs/semana10_lab_grafico_horrible.R, ~40 min, sin nota); después la
#   T4 parte 1 (labs/semana10_tarea3_esqueleto.R, calificada).
# =============================================================================
