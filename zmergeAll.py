import os
from datetime import datetime


def combinar_archivos_recursivos(directorio_entrada, archivo_salida):
    try:
        # Abre el archivo de salida en modo de escritura
        with open(archivo_salida, 'w', encoding='utf-8') as archivo_combined:
            # Recorre directorios y subdirectorios de forma recursiva
            for raiz, dirs, archivos in os.walk(directorio_entrada):
                print(f"Explorando directorio: {raiz}")
                for archivo in archivos:
                    archivo_path = os.path.join(raiz, archivo)
                    # Solo procesar archivos de texto
                    if archivo_path.lower().endswith('.dart'):
                        print(f"Procesando archivo: {archivo_path}")
                        with open(archivo_path, 'r', encoding='utf-8') as f:
                            contenido = f.read()
                            archivo_combined.write(f"{archivo_path} \n\n")
                            archivo_combined.write(contenido)
                            archivo_combined.write(
                                "\n--- Fin del archivo ---\n\n")
                    else:
                        print(f"Archivo ignorado (no es .txt): {archivo_path}")
    except Exception as e:
        print(f"Error: {e}")


def obtener_nombre_archivo_salida():
    # Obtén la fecha y hora actuales
    fecha_hora = datetime.now().strftime("%Y%m%d_%H%M%S")
    # Define el nombre del archivo con fecha y hora
    nombre_archivo = f"flutter_app_{fecha_hora}.txt"
    return nombre_archivo


# Configura el directorio de entrada
directorio_entrada = 'lib'
# Obtén el nombre del archivo de salida con fecha y hora
archivo_salida = obtener_nombre_archivo_salida()

print(f"Nombre del archivo de salida: {archivo_salida}")

combinar_archivos_recursivos(directorio_entrada, archivo_salida)
print(f"Archivos combinados en {archivo_salida}")
