#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Apr 30 14:09:03 2025

@author: cbozonnet
"""
# A program to analyse the arabidopis growth data obtained from image processing

import pandas as pd
import matplotlib.pyplot as plt

#################### Things to change ############################
df = pd.read_csv('results_full_data_set_clermont.csv')
# define custom column names 
# to adapt to the structure of the registered file name
column_names = ['r','site','tray','date','extension','buff']
# site selection (!under ''!)
site2select = '55'
# tray selection (!under '' and two digits: 01 , 02,..,10,12,...20 !!)
tray2select = '01'
##################################################################

# Step 2: Drop the 'Count' and 'Average Size' columns
df.drop(columns=['Count', 'Average Size'], inplace=True)

# Step 3: Split the 'image name' column dynamically, handling both '_' and '.'
# Use a regular expression to split by '_' and '.'
split_columns = df['Slice'].str.split(r'[_.]', expand=True)

# Step 4: Determine the maximum number of parts
max_parts = split_columns.shape[1]

# step 5: verify you provided the good number of column names,
# if not show the header of the split_columns df so the user can rectify
if len(column_names) != max_parts:
    print("The number of custom column names provided does not match the number of parts in the split columns.")
    print("Please rectify the column names based on the following header:")
    print(split_columns.head())
else:
    # Step 6: Rename the new columns dynamically
    split_columns.columns = column_names
    
    # Step 7: Keep only the 'site', 'tray', 'date' columns
    columns_to_keep = ['site', 'tray', 'date']
    split_columns = split_columns[columns_to_keep]

    # Step 8: Concatenate the selected columns back to the original DataFrame
    df = pd.concat([df, split_columns], axis=1)
    
    # Step 9: Drop the 'Slice' column as it is not needed anymore
    df.drop(columns=['Slice'], inplace=True)

    # Step 10: Show the header so the user can check the validity of the format
    print("DataFrame header after processing:")
    print(df.head())

    ################### Step 11: Plot the data for each 'pot index' ##########
    unique_pots = df['Pot number'].unique()
    
    # Skip the first two pots (colored ruler)
    unique_pots = unique_pots[2:]
    
    # Find the maximum value of 'Area' within this site and tray for normalization
    sub_df = df[(df['site']==site2select) & (df['tray']==tray2select)]
    max_area = sub_df['%Area'].max()
    
    # Create a figure with an 8x5 grid of subplots
    fig, axs = plt.subplots(5, 8, figsize=(20, 15))

    # Flatten the array of axes for easier indexing
    axs = axs.flatten()

    # Blank the first two positions
    axs[0].axis('off')
    axs[1].axis('off')
    
    # Plot the data for each pot index
    for i, pot in enumerate(unique_pots):
        pot_data = df[(df['Pot number'] == pot) & (df['site']==site2select) & (df['tray']==tray2select)]
        axs[i + 2].plot(pot_data['date'], pot_data['%Area']/max_area, linewidth=2, marker='o')
        #axs[i + 2].set_title(f'Pot {pot}')
        axs[i + 2].set_xticks([])
        axs[i + 2].set_yticks([])
        axs[i + 2].set_ylim(0, 1)
        axs[i + 2].text(0.05, 0.95, f'{pot}', transform=axs[i + 2].transAxes, fontsize=16, verticalalignment='top')
        
    # Remove any unused subplots
    for j in range(i + 3, len(axs)):
        axs[j].axis('off')

    # Adjust layout
    # Add a title to the entire figure
    fig.suptitle(f'Growth plots for site {site2select} and tray {tray2select}', fontsize=28)
    plt.tight_layout()
    plt.show()