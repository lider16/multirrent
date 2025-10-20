# Guías de Desarrollo - Proyecto Flutter

## Estructura de Archivos
- `lib/` - Código fuente principal
- `lib/models/` - Modelos de datos
- `lib/services/` - Servicios y API calls
- `lib/screens/` - Pantallas de la aplicación
- `lib/widgets/` - Widgets reutilizables (**PRIORIDAD ALTA**)
- `lib/widgets/buttons/` - Botones reutilizables
- `lib/widgets/common/` - Widgets comunes
- `lib/controllers/` - Controladores de estado
- `lib/utils/` - Utilidades y helpers
- `lib/constants/` - Constantes de la aplicación
- `lib/theme/` - Temas, colores y estilos

## Nomenclatura
- **Clases**: PascalCase (ej: `ProductModel`)
- **Variables**: camelCase (ej: `userName`)
- **Archivos**: snake_case (ej: `product_model.dart`)
- **Constantes**: UPPER_SNAKE_CASE (ej: `API_BASE_URL`)

## Reglas de Código
1. Usar `const` constructors cuando sea posible
2. Implementar manejo de errores con try-catch
3. Usar null safety correctamente
4. Documentar funciones públicas
5. Separar lógica de negocio de la UI
6. Usar Provider/Riverpod para state management

## Reglas para Código Limpio
1. **Un archivo, una responsabilidad**: Máximo 200-300 líneas por archivo
2. **Nombres claros y descriptivos**: Evitar abreviaciones confusas
3. **Componentes reutilizables (PRIORIDAD MÁXIMA)**:
   - **OBLIGATORIO**: Usar widgets base como `BaseButton`, `BaseTextField`
   - **PROHIBIDO**: Crear botones o estilos directamente en pantallas
   - Usar constantes desde `app_constants.dart` y `app_theme.dart`
   - Sistema de colores: `AppColors`, estilos: `AppTextStyles`, espaciados: `AppSpacing`
4. **Manejo de estado organizado**: Screen → Controller → Service → Model
5. **Documentación**: Documentar clases y métodos importantes
6. **Caracteres y codificación**: Evitar caracteres especiales (ñ, acentos) en nombres de código. Usar solo ASCII.

## Interacción con el Agente de Desarrollo
Cuando solicites cambios o ajustes al código al agente (GitHub Copilot), este debe:

1. **Revisar las reglas**: Asegurarse de que cualquier cambio cumpla con estas guías de desarrollo.
2. **Solicitar contexto claro**: Pedir información adicional sobre la aplicación si no está clara la funcionalidad, estructura o impacto del cambio.
3. **Explicar el plan**: Describir detalladamente qué cambios se proponen, por qué se hacen y cómo afectan al código existente.
4. **Esperar autorización**: No realizar ningún cambio hasta que el desarrollador (tú) lo autorice explícitamente.

Esto garantiza que todos los cambios sean intencionales, consistentes y alineados con las mejores prácticas del proyecto.

## Patrones a Seguir
- Repository Pattern para datos
- MVVM o Clean Architecture
- Dependency Injection
- Responsive Design
- Design System Pattern (sistema de diseño consistente)