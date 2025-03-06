import json
import os
import re
from pathlib import Path

# Configuración
input_notebook = "07_Organized_Cluster_Analysis.ipynb"
output_notebook = "Cluster_Analysis.ipynb"

def fix_notebook():
    print(f"Procesando notebook: {input_notebook}")
    
    # Verificar que el archivo de entrada existe
    if not os.path.exists(input_notebook):
        print(f"Error: El archivo {input_notebook} no existe.")
        return False
    
    # Leer el archivo de notebook
    try:
        with open(input_notebook, "r", encoding="utf-8") as f:
            notebook = json.load(f)
    except Exception as e:
        print(f"Error al leer el notebook: {e}")
        return False
    
    # Realizar modificaciones en el notebook
    notebook_modificado = corregir_notebook(notebook)
    
    # Guardar el notebook modificado
    try:
        with open(output_notebook, "w", encoding="utf-8") as f:
            json.dump(notebook_modificado, f, indent=1, ensure_ascii=False)
        print(f"Notebook corregido guardado como: {output_notebook}")
        return True
    except Exception as e:
        print(f"Error al guardar el notebook: {e}")
        return False

def corregir_notebook(notebook):
    """Realiza todas las correcciones necesarias en el notebook"""
    
    # Guardar una copia para no modificar el original
    notebook_corregido = notebook.copy()
    
    # Recorrer todas las celdas y hacer modificaciones según sea necesario
    for i, celda in enumerate(notebook_corregido['cells']):
        # Solo procesamos celdas de código
        if celda['cell_type'] == 'code':
            # Obtener el código de la celda
            codigo = ''.join(celda['source'])
            
            # Aplicar correcciones al código de la celda
            codigo_corregido = codigo
            
            # 1. Corregir rutas de archivos y directorios
            codigo_corregido = corregir_rutas(codigo_corregido)
            
            # 2. Corregir nombres de archivos y patrones de búsqueda
            codigo_corregido = corregir_nombres_archivos(codigo_corregido)
            
            # 3. Corregir la función de procesamiento de CSV 
            codigo_corregido = corregir_procesamiento_csv(codigo_corregido)
            
            # 4. Corregir la función de procesamiento de imágenes
            codigo_corregido = corregir_procesamiento_imagenes(codigo_corregido)
            
            # 5. Corregir la última celda (función main)
            codigo_corregido = corregir_funcion_main(codigo_corregido)
            
            # 6. Mejorar manejo de errores
            codigo_corregido = mejorar_manejo_errores(codigo_corregido)
            
            # Actualizar el código en la celda
            celda['source'] = [codigo_corregido]
    
    return notebook_corregido

def corregir_rutas(codigo):
    """Corrige problemas con rutas de archivos"""
    
    # Verificación de existencia de directorios
    if "source_dir = " in codigo:
        codigo = re.sub(
            r'source_dir = "(.*?)"', 
            'source_dir = "../Output/Results_Clusters/Statistics/"\n'
            '# Buscar primero en k2_analysis si existe, sino usar el directorio principal\n'
            'k2_dir = os.path.join(source_dir, "k2_analysis")\n'
            'if os.path.exists(k2_dir) and os.path.isdir(k2_dir):\n'
            '    source_dir = k2_dir\n'
            'print(f"Usando directorio fuente: {source_dir}")', 
            codigo
        )
    
    # Verificación dinámica de las carpetas
    if "os.makedirs(output_dir, exist_ok=True)" in codigo:
        codigo = re.sub(
            r'os.makedirs\(output_dir, exist_ok=True\)',
            '# Crear directorios y verificar existencia\n'
            'for directory in [output_dir, images_dir]:\n'
            '    try:\n'
            '        os.makedirs(directory, exist_ok=True)\n'
            '        print(f"Directorio creado/verificado: {directory}")\n'
            '    except Exception as e:\n'
            '        print(f"Error al crear directorio {directory}: {e}")',
            codigo
        )
    
    return codigo

def corregir_nombres_archivos(codigo):
    """Corrige patrones de búsqueda de archivos"""
    
    # Hacer más flexible la detección de archivos CSV
    if "sheet_name_map = {" in codigo:
        # Hacer más robusto el mapeo de nombres de hojas
        codigo = re.sub(
            r'sheet_name_map = \{(.*?)\}',
            '''sheet_name_map = {
        "cluster_comparison": "Cluster Differences",
        "program_comparison_overall": "Program Differences",
        "program_comparison_cluster0": "Cluster 0 Analysis",
        "program_comparison_cluster1": "Cluster 1 Analysis",
        "top20_cluster_differences": "Top 20 Cluster Vars",
        "top20_program_differences": "Top 20 Program Vars",
        "top10_program_differences_cluster0": "Top 10 C0 Vars",
        "top10_program_differences_cluster1": "Top 10 C1 Vars",
        "variable_importance": "Variable Importance"
    }''',
            codigo, 
            flags=re.DOTALL
        )
    
    # Hacer más flexible el mapeo de nombres de imágenes
    if "image_name_map = {" in codigo:
        codigo = re.sub(
            r'image_name_map = \{(.*?)\}',
            '''image_name_map = {
        "summary_dashboard": "01_Summary_Dashboard.png",
        "top_cluster_variables": "02_Top_Cluster_Variables.png",
        "top_program_variables": "03_Top_Program_Variables.png",
        "program_effect_sizes": "04_Program_Effect_Sizes.png",
        "program_distribution_clusters": "05_Program_Distribution.png",
        "cluster0_program_differences": "06_Cluster0_Program_Differences.png",
        "cluster1_program_differences": "07_Cluster1_Program_Differences.png",
        "variable_importance": "08_Variable_Importance.png",
        "category_funding_analysis": "09_Funding_Variables.png",
        "category_program_design_analysis": "10_Program_Design_Variables.png",
        "category_program_structure_analysis": "11_Program_Structure_Variables.png",
        "category_targeting_analysis": "12_Targeting_Variables.png",
        "z_scores_funding_clusters": "13_Z_Scores_Funding.png",
        "z_scores_program_structure_clusters": "14_Z_Scores_Program_Structure.png",
        "z_scores_targeting_clusters": "15_Z_Scores_Targeting.png"
    }''',
            codigo,
            flags=re.DOTALL
        )
    
    return codigo

def corregir_procesamiento_csv(codigo):
    """Corrige la función de procesamiento de archivos CSV"""
    
    # Mejorar la detección de archivos CSV
    if "csv_files = [f for f in os.listdir(source_dir) if f.endswith('.csv')]" in codigo:
        codigo = re.sub(
            r'csv_files = \[f for f in os\.listdir\(source_dir\) if f\.endswith\(\'\.csv\'\)\]',
            '''# Buscar todos los archivos CSV en el directorio source_dir
    csv_files = [f for f in os.listdir(source_dir) if f.endswith('.csv')]
    
    # Verificar que encontramos archivos
    if not csv_files:
        print(f"ADVERTENCIA: No se encontraron archivos CSV en {source_dir}")
        print("Buscando en directorios alternativos...")
        
        # Intentar buscar en el directorio padre
        parent_dir = os.path.dirname(source_dir)
        alt_csv_files = [f for f in os.listdir(parent_dir) if f.endswith('.csv')]
        
        if alt_csv_files:
            print(f"Se encontraron {len(alt_csv_files)} archivos CSV en {parent_dir}")
            csv_files = alt_csv_files
            source_dir = parent_dir
        else:
            print("No se encontraron archivos CSV en directorios alternativos")''',
            codigo
        )
    
    # Mejorar el procesamiento de cada archivo CSV
    if "# Read the CSV" in codigo:
        codigo = re.sub(
            r'# Read the CSV\s+df = pd\.read_csv\(file_path\)',
            '''# Read the CSV
        try:
            df = pd.read_csv(file_path)
            print(f"Procesando: {csv_file} - {df.shape[0]} filas, {df.shape[1]} columnas")
        except Exception as e:
            print(f"Error al leer {file_path}: {e}")
            continue  # Pasar al siguiente archivo''',
            codigo
        )
    
    # Mejorar determinación del nombre de la hoja
    if "# Determine sheet name" in codigo:
        codigo = re.sub(
            r'# Determine sheet name(.*?)sheet_name = os\.path\.splitext\(csv_file\)\[0\]\[:31\]',
            '''# Determine sheet name
        base_filename = os.path.splitext(csv_file)[0]
        
        # Buscar coincidencias parciales en el mapeo
        sheet_name = None
        for pattern, name in sheet_name_map.items():
            if pattern in base_filename:
                sheet_name = name
                break
                
        # Si no hay coincidencia, usar el nombre del archivo (truncado si es necesario)
        if sheet_name is None:
            sheet_name = base_filename[:31]  # Excel limita nombres de hojas a 31 caracteres''',
            codigo,
            flags=re.DOTALL
        )
    
    return codigo

def corregir_procesamiento_imagenes(codigo):
    """Corrige la función de procesamiento de imágenes"""
    
    # Mejorar la búsqueda de archivos de imagen
    if "png_files = [f for f in os.listdir(source_dir) if f.endswith('.png')]" in codigo:
        codigo = re.sub(
            r'png_files = \[f for f in os\.listdir\(source_dir\) if f\.endswith\(\'\.png\'\)\]',
            '''# Buscar archivos PNG en el directorio fuente y en subdirectorios
    png_files = [f for f in os.listdir(source_dir) if f.endswith('.png')]
    
    # Si no hay archivos PNG, buscar en el directorio principal de figuras
    if not png_files:
        figures_source = "../Output/Results_Clusters/Figures/"
        if os.path.exists(figures_source) and os.path.isdir(figures_source):
            alt_png_files = [f for f in os.listdir(figures_source) if f.endswith('.png')]
            if alt_png_files:
                print(f"Se encontraron {len(alt_png_files)} imágenes en {figures_source}")
                png_files = alt_png_files
                source_dir = figures_source''',
            codigo
        )
    
    # Mejorar el procesamiento de cada imagen
    if "for png_file in png_files:" in codigo:
        codigo = re.sub(
            r'for png_file in png_files:(.*?)new_name = png_file',
            '''for png_file in png_files:
        source_path = os.path.join(source_dir, png_file)
        
        if not os.path.exists(source_path):
            print(f"Advertencia: No se encuentra {source_path}")
            continue
            
        # Obtener el nombre base sin extensión
        base_name = os.path.splitext(png_file)[0]
        
        # Buscar coincidencias parciales en el mapeo
        new_name = None
        for pattern, mapped_name in image_name_map.items():
            if pattern in base_name:
                new_name = mapped_name
                break
                
        # Si no hay coincidencia, usar el nombre original
        if new_name is None:
            new_name = png_file''',
            codigo,
            flags=re.DOTALL
        )
    
    return codigo

def corregir_funcion_main(codigo):
    """Corrige la función main para mejor manejo de errores y flujo"""
    
    if "def main():" in codigo:
        codigo = re.sub(
            r'def main\(\):(.*?)# Run the script',
            '''def main():
    print("===== INICIANDO PROCESAMIENTO DE DATOS DE CLUSTERS =====")
    
    # Verificar requisitos
    required_packages = ["pandas", "openpyxl", "docx"]
    
    for package in required_packages:
        try:
            __import__(package)
            print(f"✓ Paquete {package} instalado correctamente")
        except ImportError:
            print(f"✗ ERROR: Paquete {package} no está instalado. Instálalo con: pip install {package}")
            return
    
    try:
        print("\\nProcesando archivos CSV y creando Excel...")
        sheet_name_map = process_csv_files()
        if not sheet_name_map:
            print("No se pudieron procesar los archivos CSV correctamente.")
            return
            
        print("\\nOrganizando archivos de imágenes...")
        image_info = process_images()
        
        print("\\nCreando documento Word...")
        create_word_document(sheet_name_map, image_info)
        
        print("\\n===== TODAS LAS TAREAS COMPLETADAS =====")
        print(f"- Archivo Excel: {excel_path}")
        print(f"- Documento Word: {word_path}")
        print(f"- Carpeta de imágenes: {images_dir}")
        
    except Exception as e:
        import traceback
        print(f"\\n✗ ERROR EN LA EJECUCIÓN: {e}")
        print(traceback.format_exc())
        print("\\nIntentando continuar con las tareas restantes...")

# Run the script''',
            codigo,
            flags=re.DOTALL
        )
    
    return codigo

def mejorar_manejo_errores(codigo):
    """Añade mejor manejo de errores en varias partes del código"""
    
    # Si no existen estructuras específicas de manejo de errores
    if "except Exception as e:" not in codigo:
        # Añadir try-except en funciones principales
        for func_name in ["process_csv_files", "process_images", "create_word_document"]:
            if f"def {func_name}" in codigo:
                # Encuentra la definición de la función
                pattern = rf"def {func_name}\([^)]*\):(.*?)return"
                match = re.search(pattern, codigo, re.DOTALL)
                
                if match:
                    # Obtiene el cuerpo de la función
                    function_body = match.group(1)
                    
                    # Envuelve el cuerpo en un try-except
                    new_body = f"""
    try:
{function_body}    
        return result  # Asumiendo que la función devuelve algo llamado 'result'
    except Exception as e:
        print(f"Error en {func_name}: {{e}}")
        import traceback
        print(traceback.format_exc())
        return """
                    
                    # Reemplaza el cuerpo original con el nuevo
                    codigo = re.sub(pattern, f"def {func_name}([^)]*): {new_body}", codigo, flags=re.DOTALL)
    
    return codigo

if __name__ == "__main__":
    # Ejecutar la función principal
    if fix_notebook():
        print("\nProceso completado con éxito. Puedes abrir el archivo Cluster_Analysis.ipynb")
    else:
        print("\nSe encontraron errores durante el proceso. Revisa los mensajes anteriores.")