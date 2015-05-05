# Mining implicit knowledge

**! THIS APPROACH DOESN'T WORK because the resulting SQL scripts are too big to import**

For the seminar ['Knowledge Mining'](http://knowmin2015.blogspot.de/) at [Hasso-Plattner-Institute](http://hpi.de/en/) in Potsdam, Germany, we are working on extracting knowlegde from DBpedia Categories.

## How it could work

The script [processDumps.py](scripts/processDumps.py) creates **SQL scripts for five tables**
* **categories.sql** creates the **categories table** and inserts data from the article_categories DBpedia dump  
<table>
  <tr>
    <td>subject</td>
    <td>category</td>
  </tr>
</table>
* **statements.sql** creates the **statements table** and inserts data from the mappingbased_properties DBpedia dump
<table>
  <tr>
    <td>subject</td>
    <td>predicate</td>
    <td>object</td>
  </tr>
</table>
* **categories_join.sql** creates the **categories_join** table and inserts data from the join of the categories and the statements table  
<table>
  <tr>
    <td>category</td>
    <td>subject</td>
    <td>predicate</td>
    <td>object</td>
  </tr>
</table>
* **evaluation_tables.sql** crates the **evaluation_results** and the **suggestions table**  
	* Results:  <table>
                <tr>
                  <td>category</td>
                  <td>subject</td>
                  <td>predicate</td>
                  <td>object</td>
                  <td>probability</td>
                </tr>
              </table>
	* Suggestions:  <table>
                    <tr>
                      <td>status</td>
                      <td>subject</td>
                      <td>predicate</td>
                      <td>object</td>
                      <td>probability</td>
                    </tr>
                  </table>

  
The script [evaluate.php](scripts/evaluate.php) inserts data into the latter two tables.

  
[run.sh](run.sh) executes the scripts.

## Setting it up

* download and extract **dumps** (see [README](dumps/README.md))
* **crate a database** and adjust the params for the db connection in evaluate.php
* execute
	* **processDumps.py**
	* **import** the **SQL scripts** into your db (categories_join after catergories and statements!)
	* **evaluate.php**  
* or 
	* **run.sh** (but you still have to import the sql files into your db manually)
