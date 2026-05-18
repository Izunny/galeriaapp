# Implementación de Favoritos, Historial y Descargas

Este plan detalla los pasos para agregar la funcionalidad de almacenar y visualizar localmente las imágenes que el usuario marca como favoritas, que descarga o que simplemente visualiza.

## User Review Required
- **Uso de SharedPreferences:** Se utilizará `SharedPreferences` para guardar estas listas (almacenando el JSON de cada imagen). Esto es ideal para una cantidad moderada de datos y evita introducir nuevas dependencias de bases de datos como SQFlite o Hive por ahora. Si planeas que los usuarios guarden miles de imágenes, podríamos necesitar una base de datos real, pero SharedPreferences es excelente para empezar.

## Proposed Changes

### Data & Domain Layer (Almacenamiento Local)
Se creará un nuevo repositorio y providers para manejar el almacenamiento y estado de estas listas locales.

#### [NEW] `lib/data/repositories/local_storage_repository.dart`
- Clase `LocalStorageRepository` que manejará el guardado/carga de listas de `WallpaperModel` en `SharedPreferences`.
- Claves: `'favorites'`, `'history'`, `'downloads'`.

#### [NEW] `lib/presentation/providers/local_data_provider.dart`
- Providers de Riverpod para manejar el estado de cada lista: `favoritesProvider`, `historyProvider`, `downloadsProvider`.
- Expondrán métodos para agregar, eliminar y verificar si un elemento existe en sus respectivas listas.

### UI Components (Pantallas y Navegación)

#### [NEW] `lib/presentation/screens/saved_wallpapers_screen.dart`
- Pantalla reutilizable que recibe un título (ej: "Favoritos") y muestra una cuadrícula de imágenes. Reutilizará la misma estética del grid principal.

#### [MODIFY] `lib/presentation/screens/home_screen.dart`
- Actualizar el `onTap` de las opciones del Drawer para navegar a `SavedWallpapersScreen` pasándole el provider adecuado (Favoritos, Historial o Descargas).

#### [MODIFY] `lib/presentation/screens/detail_screen.dart`
- **Favoritos:** El botón de corazón verificará si la imagen actual está en `favoritesProvider` (mostrando un corazón lleno o vacío) y permitirá agregar/quitar.
- **Historial:** Al abrir la pantalla (`initState`), se registrará automáticamente la imagen en `historyProvider`.
- **Descargas:** Al terminar una descarga exitosa, se agregará la imagen a `downloadsProvider`.

## Verification Plan
1. **Manual Verification:** 
   - Abrir una imagen y verificar que aparezca en "Historial".
   - Tocar el botón de Me gusta y verificar el cambio de icono.
   - Descargar la imagen y verificar notificación de éxito.
   - Navegar desde el menú lateral a cada una de las 3 secciones y verificar que las imágenes correspondientes se muestran correctamente.
   - Reiniciar la aplicación para confirmar que los datos persisten localmente.
