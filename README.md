# Plataforma de Descubrimiento y Validación de Ideas

Sistema backend diseñado para registrar, centralizar y validar ideas de negocio de personas emprendedoras[cite: 1]. La plataforma conecta el perfil socioeconómico del emprendedor con sus ideas, manteniendo un historial estructurado de chats de validación asistida[cite: 1].

---

## Propósito del Proyecto

El acompañamiento en etapas tempranas suele ser disperso e indocumentado[cite: 1]. Este proyecto soluciona dicho problema permitiendo:

* **Conectar perfiles e ideas:** Vinculación directa entre el perfil del usuario y las propuestas registradas[cite: 1].
* **Persistencia de conversaciones:** Registro cronológico de chats de validación asistida por IA[cite: 1].
* **Puntuación de oportunidad:** Asignación de un puntaje comparable (`opportunity_score`) a cada idea para objetivar la evaluación[cite: 1].

---

## Arquitectura del Dominio y Modelo EER

El diseño del modelo relacional implementa las siguientes entidades y decisiones de modelado[cite: 1]:

* **`persons` & `users` (1:1):** Separación de datos personales y credenciales de acceso para aislar información sensible[cite: 1].
* **`ideas` (1:N):** Cada usuario puede registrar múltiples ideas describiendo un problema de negocio[cite: 1].
* **`chats` (1:1):** Entidad débil vinculada a la idea mediante su clave primaria `id_idea`[cite: 1].
* **`messages` (1:N):** Historial cronológico de mensajes entre el emprendedor y el asistente, con contenido almacenado en formato `JSON` para dar flexibilidad de metadatos[cite: 1].

### Diagrama Entidad-Relación

```
  +-------------+        1:1        +-----------+        1:N        +-----------+
  |   PERSONS   |<----------------->|   USERS   |<----------------->|   IDEAS   |
  +-------------+                   +-----------+                   +-----+-----+
                                                                          | 1:1
                                                                          v
  +-------------+        1:N        +-----------+                   +-----------+
  |  MESSAGES   |<------------------|   CHATS   |<------------------| (Entidad  |
  +-------------+                   +-----------+                   |   Débil)  |
                                                                    +-----------+

```

---

## Esquema de Base de Datos

| Tabla | Clave Primaria | Claves Foráneas | Descripción |
| --- | --- | --- | --- |
| **`persons`** | `id_person`[cite: 1] | — | Profiling socioeconómico y nivel de experiencia[cite: 1]. |
| **`users`** | `id_user`[cite: 1] | `id_person` (UNIQUE)[cite: 1] | Credenciales de acceso (email y password hash)[cite: 1]. |
| **`ideas`** | `id_idea`[cite: 1] | `id_user`[cite: 1] | Problema planteado y puntaje de oportunidad[cite: 1]. |
| **`chats`** | `id_idea`[cite: 1] | `id_idea`[cite: 1] | Contenedor de conversación asociado 1:1 a la idea[cite: 1]. |
| **`messages`** | `id_message`[cite: 1] | `id_idea`[cite: 1] | Mensajes enviados con rol (`user`/`assistant`) y payload JSON[cite: 1]. |

---

## Requisitos de Negocio Soportados

1. Trazabilidad completa de las ideas registradas por un usuario junto a su puntaje[cite: 1].
2. Recuperación del historial completo de conversación de cualquier idea[cite: 1].
3. Análisis cruzado entre las ideas mejor valoradas y el perfil demográfico/socioeconómico del usuario[cite: 1].

---

## Equipo de Desarrollo

* **Dalan Roa**[cite: 1]
* **Juan Galindo**[cite: 1]
* **Daniel Martinez**[cite: 1]
* **Ivan Ocampo**[cite: 1]

---

