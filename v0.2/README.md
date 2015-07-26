# Mining implicit knowledge

For the seminar ['Knowledge Mining'](http://knowmin2015.blogspot.de/) at [Hasso-Plattner-Institute](http://hpi.de/en/) in Potsdam, Germany, we are working on extracting knowlegde from DBpedia Categories.

## How it could work

The class [DumpImporter.php](source/DumpImporter.php) creates and fills two tables **categories** and **statements** from the article_categories und the mappingbased_properties DBpedia dump.
* categories table  
<table>
  <tr>
    <td>category</td>
    <td>subject</td>
  </tr>
</table>
* statements table
<table>
  <tr>
    <td>subject</td>
    <td>predicate</td>
    <td>object</td>
  </tr>
</table>
 
The class [PreEvaluator.php](source/PreEvaluator.php) also creates two tables **join_categories_statements** and **suggesttions** and fills the former with join-tuples from the categories and the statements table
* join_categories_statements table
<table>
  <tr>
    <td>category</td>
    <td>subject</td>
    <td>predicate</td>
    <td>object</td>
  </tr>
</table>
* suggestions table:
<table>
  <tr>
    <td>status</td>
    <td>subject</td>
    <td>predicate</td>
    <td>object</td>
    <td>probability</td>
  </tr>
</table>
  
The class [Evaluator.php](source/Evaluator.php) inserts data into the latter table.
  
[execute.php](source/execute.php) executes everything.

The class [Helper.php](source/Helper.php) constains some Methods that are used by all other classes.

## Setting it up

* you need to have installed PHP and MySQL on a **server** (e.g. [XAMPP](https://www.apachefriends.org/index.html))
* download and extract **dumps** (see [README](dumps/README.md))
* **crate a database** and adjust the params for the db connection in Helper.php
* run **execute.php**:  
```bash  
//from root directory of repo    
cd source   
php execute.php   
```