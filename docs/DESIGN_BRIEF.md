# DESIGN_BRIEF.md — Encargo de diseño (opcional, solo proyectos con frontend)

Plantilla para encargar (a un diseñador o a otra IA) un rediseño de UI que siga siendo
**implementable** sobre el frontend actual y **no rompa** el contrato del backend ni la
suite de tests. Bórrala si tu proyecto no tiene frontend.

Regla de oro del brief: **diseña con los nombres y valores de campo REALES** (nunca inventes
campos), y marca explícitamente qué textos/atributos NO pueden cambiar porque hay tests que
dependen de ellos.

---

## 1. Producto y usuario
- Qué es, para quién, qué tarea resuelve en una frase.

## 2. Principios de diseño
- 3-5 principios que guían las decisiones (ej. "densidad de información alta pero legible").

## 3. Arquitectura de información
- Mapa de secciones/rutas y cómo se relacionan.

## 4. Contrato de datos real
- Entidades y **nombres de campo exactos** que la UI consume (copiados del modelo/seed real).

## 5. Spec por pantalla
- Para cada pantalla: estados **loading / vacío / error / con datos**.

## 6. Inventario de componentes
- Lista de primitivos y compuestos reutilizables (Button, Pill, Card, Modal, Table…).

## 7. Tokens sugeridos (explícitamente "libres de mejorar")
- Color, tipografía, radios, espaciado. Marca cuáles son fijos (marca/handoff) y cuáles orientativos.

## 8. Accesibilidad (concreta y testable)
- Roles ARIA, labels, focus visible, contraste. Los tests e2e se anclan a atributos accesibles.

## 9. Responsive (mobile-first)
- Breakpoints y qué se reorganiza en cada uno.

## 10. Restricciones técnicas de implementación
- Stack fijo, API same-origin, sin dependencias nuevas sin checkpoint.

## 11. ⚠️ Textos y atributos que NO pueden cambiar (o rompen tests) — el contrato real
- Lista literal de copys, `data-testid`, roles y labels de los que dependen los tests.
  **Esta sección es vinculante**: cambiarlos rompe la suite.

## 12. Entregable esperado (formatos por orden de preferencia)
- Ej. HTML+CSS autocontenido > specs por componente > mockups. Sin adjuntos que no se puedan versionar.
