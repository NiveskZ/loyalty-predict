# %%
import os
import dotenv

from kaggle import api

dotenv.load_dotenv('../../.env')

os.environ['KAGGLE_USERNAME'] = 'username'
os.environ['KAGGLE_KEY'] = 'key'
# %%
datasets = [
    'teocalvo/teomewhy-loyalty-system',
    'teocalvo/teomewhy-education-platform'
]

for d in datasets:

    dataset_name = d.split("teomewhy-")[-1]
    print(dataset_name)
    path = f'./data/{dataset_name}'

    api.dataset_download_file(d, 'database.db',path=path)
# %%
