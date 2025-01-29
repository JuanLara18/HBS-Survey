import pandas as pd
import numpy as np
from umap import UMAP
import matplotlib.pyplot as plt
from sklearn.preprocessing import StandardScaler, LabelEncoder

# Read the Stata exported data
data = pd.read_csv("Results/temp_data_for_umap.csv")

# Separate features for UMAP
features = [col for col in data.columns if col.startswith('p_')]
X = data[features].copy()

# Function to convert range strings to numeric values
def convert_range_to_numeric(value):
    if pd.isna(value):
        return np.nan
    if isinstance(value, (int, float)):
        return float(value)
    
    try:
        if ' - ' in str(value):
            lower, upper = map(float, str(value).split(' - '))
            return (lower + upper) / 2
        return float(value)
    except:
        return np.nan

# Convert each column to numeric
for column in X.columns:
    X[column] = X[column].apply(convert_range_to_numeric)

# Drop columns with too many missing values
missing_threshold = 0.5
X = X.dropna(axis=1, thresh=len(X) * (1 - missing_threshold))

# Fill remaining missing values with column means
X = X.fillna(X.mean())

# Standardize the features
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# Perform UMAP dimension reduction
reducer = UMAP(n_components=2, random_state=42, n_neighbors=15, min_dist=0.1)
embedding = reducer.fit_transform(X_scaled)

# Create DataFrame with UMAP coordinates
umap_df = pd.DataFrame(embedding, columns=['UMAP1', 'UMAP2'])
umap_df['program_type'] = data['program_type']

# Convert cluster labels to numeric values
label_encoders = {}
for k in [2, 3, 4]:
    column_name = f'prog_clus{k}'
    if column_name in data.columns:
        le = LabelEncoder()
        umap_df[f'cluster{k}'] = le.fit_transform(data[column_name])
        label_encoders[k] = le

# Save UMAP coordinates
umap_df.to_csv("Results/umap_coordinates.csv", index=False)

# Program Type visualization
plt.figure(figsize=(12, 8))
scatter = plt.scatter(embedding[:, 0], embedding[:, 1], 
                     c=data['program_type'],
                     cmap='coolwarm',
                     alpha=0.7,
                     s=100)
colorbar = plt.colorbar(scatter)
colorbar.set_label('Program Type (0=Upskilling, 1=Reskilling)', fontsize=10)
plt.title('UMAP Projection by Program Type', fontsize=14, pad=20)
plt.xlabel('UMAP Dimension 1', fontsize=12)
plt.ylabel('UMAP Dimension 2', fontsize=12)
plt.tight_layout()
plt.savefig('Output/Figures/umap_by_program.png', dpi=300, bbox_inches='tight')
plt.close()

# Cluster visualizations
for k in [2, 3, 4]:
    column_name = f'prog_clus{k}'
    if column_name in data.columns:
        plt.figure(figsize=(12, 8))
        
        # Get unique labels for legend
        unique_labels = sorted(data[column_name].unique())
        colors = plt.cm.viridis(np.linspace(0, 1, len(unique_labels)))
        
        # Create scatter plot
        for i, label in enumerate(unique_labels):
            mask = data[column_name] == label
            plt.scatter(embedding[mask, 0], embedding[mask, 1],
                       label=label,
                       color=colors[i],
                       alpha=0.7,
                       s=100)
        
        plt.title(f'UMAP Projection with {k} Clusters', fontsize=14, pad=20)
        plt.xlabel('UMAP Dimension 1', fontsize=12)
        plt.ylabel('UMAP Dimension 2', fontsize=12)
        plt.legend(title='Clusters', bbox_to_anchor=(1.05, 1), loc='upper left')
        plt.tight_layout()
        plt.savefig(f'Output/Figures/umap_cluster{k}.png', dpi=300, bbox_inches='tight')
        plt.close()