import os
import nbformat
import re
from nbconvert.preprocessors import ExecutePreprocessor

# Función para crear la estructura de directorios
def create_directory_structure():
    # Estructura de directorios base
    base_output_dir = "../Output/Results_Feature-Importance"
    figures_dir = os.path.join(base_output_dir, "Figures")
    stats_dir = os.path.join(base_output_dir, "Statistics")
    reports_dir = os.path.join(base_output_dir, "Reports")
    
    # Directorios específicos para análisis
    model_comparisons_dir = os.path.join(figures_dir, "Model_Comparisons")
    feature_importance_dir = os.path.join(figures_dir, "Feature_Importance")
    shap_dir = os.path.join(figures_dir, "SHAP_Analysis")
    
    # Crear todos los directorios
    for directory in [
        base_output_dir, 
        figures_dir, 
        stats_dir, 
        reports_dir,
        model_comparisons_dir,
        feature_importance_dir,
        shap_dir
    ]:
        os.makedirs(directory, exist_ok=True)
        
    print(f"Estructura de directorios creada:")
    print(f"- Base: {base_output_dir}")
    print(f"- Figuras: {figures_dir}")
    print(f"- Estadísticas: {stats_dir}")
    print(f"- Reportes: {reports_dir}")
    print(f"- Comparación de Modelos: {model_comparisons_dir}")
    print(f"- Importancia de Características: {feature_importance_dir}")
    print(f"- Análisis SHAP: {shap_dir}")
    
    return {
        'base': base_output_dir,
        'figures': figures_dir,
        'stats': stats_dir,
        'reports': reports_dir,
        'model_comparisons': model_comparisons_dir,
        'feature_importance': feature_importance_dir,
        'shap': shap_dir
    }

# Función para modificar el contenido del notebook
def modify_notebook_content(input_notebook_path, output_notebook_path, directories):
    # Leer el notebook original
    with open(input_notebook_path, 'r', encoding='utf-8') as f:
        notebook = nbformat.read(f, as_version=4)
    
    # Celda con la estructura de directorios
    setup_cell = {
        'cell_type': 'code',
        'metadata': {},
        'source': f'''# Configuración de directorios para los resultados
import os

# Estructura de directorios base
base_output_dir = "../Output/Results_Feature-Importance"
figures_dir = os.path.join(base_output_dir, "Figures")
stats_dir = os.path.join(base_output_dir, "Statistics")
reports_dir = os.path.join(base_output_dir, "Reports")

# Directorios específicos para cada tipo de visualización
model_comparisons_dir = os.path.join(figures_dir, "Model_Comparisons")
feature_importance_dir = os.path.join(figures_dir, "Feature_Importance")
shap_dir = os.path.join(figures_dir, "SHAP_Analysis")

# Crear todos los directorios
for directory in [
    base_output_dir, 
    figures_dir, 
    stats_dir, 
    reports_dir,
    model_comparisons_dir,
    feature_importance_dir,
    shap_dir
]:
    os.makedirs(directory, exist_ok=True)

print(f"Estructura de directorios creada:")
print(f"- Base: {{base_output_dir}}")
print(f"- Figuras: {{figures_dir}}")
print(f"- Estadísticas: {{stats_dir}}")
print(f"- Reportes: {{reports_dir}}")
''',
        'execution_count': None,
        'outputs': []
    }
    
    # Insertar celda de configuración después de las importaciones
    inserted = False
    for i, cell in enumerate(notebook.cells):
        if cell.cell_type == 'code' and 'import' in cell.source and 'warnings' in cell.source:
            notebook.cells.insert(i+1, nbformat.v4.new_code_cell(setup_cell['source']))
            inserted = True
            break
    
    # Si no se encontró un lugar adecuado, añadir al principio
    if not inserted:
        notebook.cells.insert(1, nbformat.v4.new_code_cell(setup_cell['source']))
    
    # Modificar las rutas de guardado en todo el código
    for cell in notebook.cells:
        if cell.cell_type == 'code':
            # Modificar las rutas para guardar figuras
            cell.source = re.sub(
                r'plt\.savefig\([\'"](.+?)\.png[\'"]',
                r'plt.savefig(f"{feature_importance_dir}/\1.png"',
                cell.source
            )
            
            # Modificar las rutas para guardar figuras SHAP
            if 'shap' in cell.source:
                cell.source = re.sub(
                    r'plt\.savefig\([\'"](.+?)\.png[\'"]',
                    r'plt.savefig(f"{shap_dir}/\1.png"',
                    cell.source
                )
            
            # Modificar las rutas para guardar comparaciones de modelos
            if 'comparison' in cell.source:
                cell.source = re.sub(
                    r'plt\.savefig\([\'"](.+?)\.png[\'"]',
                    r'plt.savefig(f"{model_comparisons_dir}/\1.png"',
                    cell.source
                )
                
            # Modificar las rutas para exportar resultados a CSV
            cell.source = re.sub(
                r'to_csv\([\'"](.+?)\.csv[\'"]',
                r'to_csv(f"{stats_dir}/\1.csv"',
                cell.source
            )
    
    # Guardar el notebook modificado
    with open(output_notebook_path, 'w', encoding='utf-8') as f:
        nbformat.write(notebook, f)
    
    print(f"Notebook modificado guardado en: {output_notebook_path}")

def main():
    # Rutas de los notebooks
    input_notebook = "07_Feature_Importance.ipynb"
    output_notebook = "Feature_Importance.ipynb"
    
    # Crear estructura de directorios
    directories = create_directory_structure()
    
    # Modificar y guardar el notebook
    modify_notebook_content(input_notebook, output_notebook, directories)
    
    print("Proceso completado. El nuevo notebook ha sido creado con rutas de exportación organizadas.")

if __name__ == "__main__":
    main()