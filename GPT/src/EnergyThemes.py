import pandas as pd
import os
from collections import Counter
import re
import matplotlib.pyplot as plt
from difflib import SequenceMatcher
from nltk.corpus import stopwords
from nltk.tokenize import word_tokenize
import nltk
import seaborn as sns

# Check if NLTK resources are already downloaded
def check_nltk_resources():
    try:
        nltk.data.find('corpora/stopwords')
    except LookupError:
        nltk.download('stopwords')

    try:
        nltk.data.find('tokenizers/punkt')
    except LookupError:
        nltk.download('punkt')

check_nltk_resources()

# Set of English stopwords
stop_words = set(stopwords.words('english'))


def similar(a, b):
    return SequenceMatcher(None, a, b).ratio()


def extract_themes_from_reasoning(reasoning):
    themes = []
    reasoning_lines = reasoning.split('\n')[1:]  # Skip the first line

    for line in reasoning_lines:
        line = line.strip()
        if re.match(r'^[0-9]+\.\s', line):
            # Extract the main idea from each line
            theme = re.sub(r'^[0-9]+\.\s', '', line.split(':', 1)[0]).strip()
            theme = re.sub(r'\*\*', '', theme).strip()  # Remove ** symbols
            themes.append(theme)
    return themes

def normalize_theme(theme):
    # Convert to lower case
    theme = theme.lower()
    # Remove punctuation
    theme = re.sub(r'[^\w\s]', '', theme)
    # Tokenize and remove stopwords
    tokens = word_tokenize(theme)
    filtered_tokens = [word for word in tokens if word not in stop_words]
    # Join tokens back into a string
    normalized_theme = ' '.join(filtered_tokens)
    return normalized_theme


def merge_similar_themes(theme_counts):
    merged_counts = Counter()
    themes = list(theme_counts.keys())

    for i, theme in enumerate(themes):
        merged = False
        normalized_theme = normalize_theme(theme)

        for merged_theme in merged_counts.keys():
            normalized_merged_theme = normalize_theme(merged_theme)
            if similar(normalized_theme, normalized_merged_theme) > 0.8:
                merged_counts[merged_theme] += theme_counts[theme]
                merged = True
                break

        if not merged:
            merged_counts[theme] = theme_counts[theme]

    return merged_counts

def apply_additional_rules(theme):
    additional_rules = {
        "Improved Code Readability & Maintainability": ["consolidated statements","code organization", "code reordering", "code structure", "modularization", "reorganized","spacing", "indentation", "formatting", "code clarity", "code consistency", "reformatting" , "readability", "naming conventions", "naming convention", "coding practices", "maintainability","maintenance", "maintain", "easy modification","simplifying", "simplified"],
        "Improved Code Efficiency": ["code efficiency", "efficiency" , "instead of"],
        "No Optimization":["no optimization","no changes", "unchanged"],
        "Improved Memory Management": ["preallocation", "preallocate", "preallocating", "initializing variables", "initialization of variables", "precompute", "precomputation", "memory allocation", "memory optimization"],
        "Improved Indexing & Loops": ["loop optimization", "optimizing loops", "loops", "looping","loop", "Loop","indexing"],
        "Improved Matrix Operations": ["matrix"],
        "Vectorization":["vectorized operation","vectorization" , "vectorized", "vectorizing"],
        "Improved Comments": ["redundant comments", "Documentation", "unnecessary comments", "removed HTML comments", "code comments", "updated comments","commenting"],
        "Improved Plots": ["subplotting", "subplot", "plots", "plot()", "improved plots", "plotting", "scatter plot", "figure"],
        "Improved Parallel Processing": ["parallel processing", "parallel computing"],
        "Removed Unnecessary Code" : ["unnecessary code", "unnecessary variables", "unused variables", "unused imports", "removal","removed","redundant calculation","redundant code","duplicate code", "code redundancy", "redundant"],
        "Improved Error Handling": ["enhanced error handling", "improved error handling"]
    }

    # Normalize the keywords in additional rules
    normalized_rules = {human_theme: [normalize_theme(keyword) for keyword in keywords]
                        for human_theme, keywords in additional_rules.items()}

    theme_lower = normalize_theme(theme)
    #print(f"Normalized theme: {theme_lower}")  # Debugging statement
    for human_theme, keywords in normalized_rules.items():
        if any(keyword in theme_lower for keyword in keywords):
            #print(f"Matched {theme_lower} to {human_theme}")  # Debugging statement
            return human_theme

    return "No Manual Inspection"
    # return ''

"""
Group automatically extracted themes according to human defined themes.
"""
def apply_theme_mapping(model_folder,theme_counts_df, theme_mapping):
    mapped_counts = Counter()
    theme_mapping_records = []  # List to store the mapping records


    """for theme, count in theme_counts_df.items():
        human_theme = theme_mapping.get(theme, apply_additional_rules(theme))
        if pd.isna(human_theme) or human_theme == '':
            human_theme = "No Manual Inspection"  # Replace NaN with 'No Manual Inspection'
            """

    for theme, count in theme_counts_df.items():
        human_theme = theme_mapping.get(theme, None)
        if pd.isna(human_theme) or human_theme is None or human_theme == '':
            human_theme = apply_additional_rules(theme)  # Use additional rules to classify the theme
            if pd.isna(human_theme) or human_theme is None or human_theme == '':
                human_theme = "No Manual Inspection"  # Replace NaN with 'No Manual Inspection'


        mapped_counts[human_theme] += count

        # Save the mapping record
        theme_mapping_records.append((theme, human_theme))

    # Convert the mapping records to a DataFrame
    mapping_df = pd.DataFrame(theme_mapping_records, columns=['Theme-Auto', 'Theme-Human'])

    # Save the mapping DataFrame to a CSV file
    output_file_path = os.path.join(model_folder, 'Mapping_Auto_to_Human_Theme.csv')
    mapping_df.to_csv(output_file_path, index=False)

    return pd.Series(mapped_counts).sort_values(ascending=False)

def process_model_folder(model_folder, theme_mapping):
    reasoning_file_path = os.path.join(model_folder, 'OptimizedMatlabScripts_reasonings.csv')
    output_file_path = os.path.join(model_folder, 'Auto-Extracted-Themes-reasoning.csv')
    detailed_output_file_path = os.path.join(model_folder, 'Detailed_OptimizedMatlabScripts_reasonings.csv')

    if os.path.exists(reasoning_file_path):
        data = pd.read_csv(reasoning_file_path)
        data['Reasoning'] = data['Reasoning'].fillna('')

        all_themes = []
        themes_list = []
        human_themes_list = []

        for reasoning in data['Reasoning'].tolist():
            themes = extract_themes_from_reasoning(reasoning)
            human_themes = [theme_mapping.get(theme, apply_additional_rules(theme)) for theme in themes]
            human_themes = [str(human_theme) if human_theme else "No Manual Inspection" for human_theme in
                            human_themes]  # Ensure all are strings and replace NaN with "No Manual Inspection"
            themes_list.append(", ".join(themes))
            human_themes_list.append(", ".join(human_themes))
            all_themes.extend(themes)

        data['Themes'] = themes_list
        data['Theme-Human'] = human_themes_list

        theme_counts = Counter(all_themes)
        merged_theme_counts = merge_similar_themes(theme_counts)

        # Sort themes by frequency
        sorted_theme_counts = dict(merged_theme_counts.most_common())

        theme_counts_df = pd.DataFrame(list(sorted_theme_counts.items()), columns=['Theme', 'Frequency'])
        theme_counts_df = theme_counts_df.set_index('Theme').sort_values(by='Frequency', ascending=False)

        theme_counts_df.to_csv(output_file_path)
        data.to_csv(detailed_output_file_path, index=False)

        print(f'Themes stored for {model_folder}')
        return theme_counts_df['Frequency'].astype(int)  # Ensure to return plain numeric values
    else:
        print(f'Reasoning file not found in {model_folder}')
        return pd.Series([], dtype='int')


def plot_top_themes(theme_counts_df, model_folder, top_n):
    # Fill NA values with 'No Manual Inspection'
    theme_counts_df = theme_counts_df.fillna('No Manual Inspection')

    top_themes = theme_counts_df.head(top_n)
    print(f"Top Themes in {model_folder}:\n", top_themes)  # Debugging line to print top themes

    # Extract and process frequencies
    try:
        frequencies = top_themes.apply(pd.to_numeric, errors='coerce').fillna(0).astype(int)
        #print("Frequencies:\n", frequencies)  # Debugging line to print frequencies
        # print("Frequency types:\n", frequencies.apply(lambda x: type(x)))  # Debugging line to check types
    except Exception as e:
        print(f"Error processing frequencies: {e}")
        return

    plt.figure(figsize=(12, 8))
    sns.set(style="whitegrid", rc={'axes.grid': False})  # Disable default grids
    colors = sns.color_palette("colorblind")[0]

    try:
        ax = top_themes.plot(kind='barh', color=colors, edgecolor='black')
        ax.set_yticklabels(top_themes.index, fontname='Times New Roman', fontsize=12)
        ax.invert_yaxis()  # Invert y-axis to display the highest frequency on top
        plt.grid(axis='x', linestyle='-', linewidth=0.7, color='gray')  # Add only vertical grids
    except Exception as e:
        print(f"Error creating bar plot: {e}")
        return

    plt.xlabel('Frequency', fontname='Times New Roman', fontsize=12)
    model_name = os.path.basename(model_folder).split('_')[-1]
    plt.ylabel(f'Themes by {model_name}', fontname='Times New Roman', fontsize=12)
    # plt.title(f'Top {top_n} Themes in Optimization Reasoning', fontname='Times New Roman', fontsize=14)
    #plt.gca().invert_yaxis()  # To display the highest frequency on top

    # Adding data labels
    for bar in ax.patches:
        plt.text(
            bar.get_width(),
            bar.get_y() + bar.get_height() / 2,
            f'{int(bar.get_width())}',
            va='center',
            ha='left',
            fontname='Times New Roman'
        )

    plt.tight_layout()
    plot_file_path = os.path.join(model_folder, 'Extracted-Themes-reasoning-plot.pdf')
    #plt.savefig(plot_file_path, dpi=300)  # Save as HD image
    plt.savefig(plot_file_path, format='pdf')  # Save as PDF
    plt.savefig(plot_file_path)
    plt.show()


def plot_combined_themes(model_theme_counts, top_n=15):
    plot_data_csv_path = os.path.join("./../resource/", 'Combined_Themes_Frequency.csv')
    # Aggregate all themes and get the top 15 themes across all models

    if os.path.exists(plot_data_csv_path):
        plot_df = pd.read_csv(plot_data_csv_path, index_col=0)
    else:
        combined_themes = Counter()
        for model, counts in model_theme_counts.items():
            top_themes = counts.head(top_n)
            combined_themes.update(top_themes.to_dict())

            # Correctly identify the top themes by name
        top_themes = [theme for theme, _ in combined_themes.most_common(top_n)]
        print("Top Themes in combined:", top_themes)  # Debugging line to print top themes

        # Create a DataFrame for plotting
        plot_data = {}
        for model in model_theme_counts:
            plot_data[model] = []
            for theme in top_themes:
                if theme in model_theme_counts[model].index:
                    plot_data[model].append(model_theme_counts[model].loc[theme])
                else:
                    plot_data[model].append(0)

        plot_df = pd.DataFrame(plot_data, index=top_themes)
        print("Plot Data:\n", plot_df)  # Debugging line to print plot data before plotting

        # Ensure all data in plot_df is numeric
        plot_df = plot_df.apply(pd.to_numeric, errors='coerce').fillna(0).astype(int)

        # Save the plot data to CSV
        plot_df.to_csv(plot_data_csv_path)

    # Plotting
    plt.figure(figsize=(10, 6))
    sns.set(style="whitegrid",rc={'axes.grid': False})
    colors = sns.color_palette("colorblind", len(plot_df.columns))

    try:
        ax = plot_df.plot(kind='barh', figsize=(14, 8), color=colors, edgecolor='black')
        ax.set_yticklabels(plot_df.index, fontname='Times New Roman',fontsize=16,color='black')
        ax.invert_yaxis()  # Invert y-axis to display the highest frequency on top
        plt.grid(axis='x', linestyle='-', linewidth=0.7, color='gray')

    except Exception as e:
        print(f"Error creating combined bar plot: {e}")
        return

    plt.xlabel('Frequency of Theme Mentions in Reasoning', fontname='Times New Roman',fontsize=18,color='black')
    plt.ylabel('Themes proposed by LLMs', fontname='Times New Roman',fontsize=18,color='black')
    #plt.title('Top 15 Themes in Optimization Reasoning Across All Models', fontname='Times New Roman',fontsize=14)

    # Customizing legend
    legend = plt.legend(title='Models', fontsize=16, title_fontsize='16', loc='lower right', frameon=True,
                        facecolor='white')
    for text in legend.get_texts():
        text.set_color("black")

    plt.tight_layout()
    plot_data_plot_path = os.path.join("./../resource/", 'Combined_Themes_Frequency.pdf')
    plt.savefig(plot_data_plot_path, format='pdf',dpi=300)  # Save as PDF
    plt.show()

def main():
    resource_folder = "./../resource/"
    base_folder = os.path.join(resource_folder, "Optimzation_results")  # Input folder

    if not os.path.exists(base_folder):
        print(f"The base folder {base_folder} does not exist.")
        return

    # Load theme mapping
    mapping_file_path = os.path.join(resource_folder, 'Themes-reasoning-human-mapping.csv')
    mapping_df = pd.read_csv(mapping_file_path)
    theme_mapping = mapping_df.set_index('Theme-Auto')['Theme-Human'].to_dict()


    # List all directories in the base folder
    model_folders = [os.path.join(base_folder, d) for d in os.listdir(base_folder) if
                     os.path.isdir(os.path.join(base_folder, d))]

    model_theme_counts = {}
    mapped_model_theme_counts = {}

    for model_folder in model_folders:
        model_name = os.path.basename(model_folder).split('_')[-1]
        #if model_name == 'llama':
        theme_counts = process_model_folder(model_folder, theme_mapping)
        model_theme_counts[model_name] = theme_counts

        #if not theme_counts.empty:
        #    plot_top_themes(theme_counts, model_folder, top_n=15)

        # Apply theme mapping
        mapped_theme_counts = apply_theme_mapping(model_folder, theme_counts, theme_mapping)
        mapped_model_theme_counts[model_name] = mapped_theme_counts

        if not mapped_theme_counts.empty:
            plot_top_themes(mapped_theme_counts, model_folder, top_n=20)

        # Save mapped theme counts for each model
        output_file_path = os.path.join(model_folder,'Mapped_Theme_Counts.csv')
        mapped_theme_counts.to_csv(output_file_path)

        # Plot combined top 15 themes across all models
    plot_combined_themes(mapped_model_theme_counts, top_n=20)

if __name__ == "__main__":
    main()
