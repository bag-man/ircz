<?php
  //$Channels = $_POST['Channel'];
  //$N = count($Channels);
  //for($i=0; $i < $N; $i++){
  //}
?>

<html>
  <head>
    <title>Random Image</title>
    <link rel="stylesheet" type="text/css" href="style.css" />
  </head>
  <body><center>
    <!--<div id=topmenu>
      <form action="random.php" method="post">
These don't do anything yet:
        <input type="checkbox" name="Channel[]" value="#Reddit" checked="checked"/> #Perl
        <input type="checkbox" name="Channel[]" value="#perl" checked="checked"/> #Reddit 
        <input type="checkbox" name="Channel[]" value="#Ubuntu" checked="checked"/> #Ubuntu
        <input type="checkbox" name="Channel[]" value="##freebsd" checked="checked"/> #FreeBSD<br><br>-->
        <?php
          include("resources/database.php");
          $result = mysql_query("SELECT * FROM images ORDER BY RAND() LIMIT 1");
          $data = mysql_fetch_array($result, MYSQL_ASSOC);
          echo "<div id=header>Click the image for another random one.</div>";
          echo "<br><div id=center><a href=random.php><input class=image type=image src=images/".$data["ID"].".".$data["FileType"]."></a></div><br>";
          echo "<div id=footer>Taken from ".$data["Channel"]." on ".$data["Date"]." original image at <a href=".$data["URL"].">".$data['URL']."</a></div>";  
        ?>
      </form>
    </div>
  </center></body>
</html>
