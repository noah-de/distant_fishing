# Where do foreign fishers fish when a country kicks them out?


## Repository structure 

```
-- data
-- distant_fishing.Rproj
-- docs
   |__tab
   |__fig
-- packrat
   |__init.R
   |__lib
   |__lib-ext
   |__lib-R
   |__packrat.lock
   |__packrat.opts
   |__src
-- raw_data
   |__monthly_foreign_fishing.csv
-- README.md
-- scripts
   |__1_collection
   |__2_processing
   |__3_analyses
   |__4_content
```

### Data

Raw data (*e.g.* directly downloaded from Global Fishing Watch) lives in the `raw_data` folder. Raw data can be modified by scripts in the `scripts/processing` folder and then exported to the `data` folder.

### Scripts

The `scripts` folder has four main sub-folders:

- `1_collection`: Scripts used to download data from GFW. This can be R or SQL queries.
- `2_processing`: Scripts that process `raw_data` and export it to `data`.
- `3_analyses`: Scripts that perform analyses of the data. This can be final and exploratory. Any results can be exported to the `data` folder.
- `4_content`: Scripts that explicitly generate content. For example, scripts that produce figures or tables. Figures and tables are exported to their respective folders in `docs/`.

### Docs

The `docs` folder contains at least two main folders: `img` and `tab`. These folders contains images and tables produced by scripts in the `scripts/content` directory. It can also contain `*Rmd` files that produce slides, manuscripts or any other sort of thing.


--------- 


