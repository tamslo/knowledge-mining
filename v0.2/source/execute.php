<?php

require "./DumpImporter.php";
require "./PreEvaluator.php";
require "./Evaluator.php";

$color = "\033[0;32m";
$default = "\033[0m";

echo "$color\nWriting dumps into database ...\n\n$default";
$dumpImporter = new DumpImporter();
$dumpImporter->execute();

echo "$color\nPreprocessing data ...\n\n$default";
$preEvaluator = new PreEvaluator();
$preEvaluator->execute();

echo "$color\nCreating suggestions ...\n\n$default";
$evaluator = new Evaluator();
$evaluator->execute();