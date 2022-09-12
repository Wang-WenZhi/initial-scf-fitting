##This module is developed by Prof. Shin-Pon JU at NSYSU on March 28 2021
package HEA; 

use strict;
use warnings;

our (%element); # density (g/cm3), arrangement, mass, lat a , lat c


$element{"Cu"} = [8.96,"fcc",63.546,3.6149,3.6149];
$element{"Ni"} = [8.908,"fcc",58.6934,3.524,3.524];
$element{"Si"} = [2.33,"dia",28.085,5.4309,5.4309];
$element{"Cr"} = [7.19,"bcc",51.9961,2.91,2.91];
$element{"Zn"} = [7.14,"hcp",65.38,2.6649,4.9468];
$element{"Nb"} = [8.57,"bcc",92.90638,3.30,3.30]; 
$element{"Ta"} = [16.69,"bcc",180.94788,3.30,3.30]; 
$element{"Ti"} = [4.506,"hcp",47.867,2.95,4.685]; 
$element{"Zr"} = [6.52,"hcp",91.224,3.232,5.147]; 
$element{"Co"} = [8.9,"hcp",58.933,2.5071,4.0695];  
$element{"Fe"} = [7.874,"bcc",55.845,2.8665,2.8665]; 
$element{"Mn"} = [7.21,"bcc",54.938,2.9214,2.9214]; 
$element{"Hf"} = [13.31,"hcp",178.49,3.1964,5.0511]; 
$element{"Ni"} = [8.908,"fcc",58.693,3.524,3.524]; 
$element{"Na"} = [0.968,"bcc",22.98977,4.2906,4.2906];
$element{"P"} = [1.823,"bcc",30.973761,1.25384,1.24896]; 
$element{"Na"} = [0.968,"bcc",22.98977,4.2906,4.2906]; 
$element{"O"} = [1.429,"fcc",15.9994,5.403,5.086]; 
$element{"P"} = [1.823,"bcc",30.973761,1.25384,1.24896]; 
$element{"Ag"} = [10.49,"fcc",107.8682,4.0853,4.0853]; 
$element{"Mn"} = [7.21,"fcc",54.938045,8.9125,8.9125]; 
$element{"Ge"} = [5.323,"fcc",72.63,5.6575,5.6575]; 
$element{"Sb"} = [6.697,"hcp",121.760,4.307,11.273]; 
$element{"Te"} = [6.24,"hcp",127.6,4.4572,5.929]; 
our (%fitted); #rc, attrac, repuls, Cmin, Cmax , Ec ,re
$fitted{"Nb"} = [3.95,0,0,0.36,2.80,7.47,2.86]; 
$fitted{"Ta"} = [3.96,0,0,0.25,2.80,8.09,2.886]; 
$fitted{"Ti"} = [4.4,0,0,1.00,1.44,4.87,2.92]; 
$fitted{"Zr"} = [4.84,0,0,1.00,1.44,6.36,3.20]; 
$fitted{"Co"} = [3.8,0,0,0.49,2.80,4.41,2.5]; 
$fitted{"Cr"} = [3.55,0.02,0.10,0.71,2.80,4.1,2.495]; 
$fitted{"Fe"} = [3.45,0.05,0.05,0.36,2.80,4.29,2.48]; 
$fitted{"Mn"} = [4.55,0,0,0.16,2.80,2.9,2.53]; 
$fitted{"Hf"} = [4.75,-0.02,-0.08,0.66,2.28,7.33,3.3]; 
$fitted{"Ni"} = [3.95,0.05,0.05,0.81,2.80,4.45,2.49]; 
$fitted{"Ag"} = [4.50,0.05,0.05,1.38,2.80]; 
$fitted{"Mn"} = [3.60,0,0,0.16,2.80]; 
$fitted{"Ge"} = [4.50,0,0,1.41,2.80];

our (%pso);  #Ec , total energy

$pso{"Nb"} = [-7.47]; 
$pso{"Ta"} = [-8.09]; 
$pso{"Ti"} = [-4.87]; 
$pso{"Zr"} = [-6.36]; 
$pso{"Co"} = [-4.41]; 
$pso{"Cr"} = [-4.1]; 
$pso{"Fe"} = [-4.29]; 
$pso{"Mn"} = [-2.90]; 
$pso{"Hf"} = [-7.33]; 
$pso{"Ni"} = [-4.45];

#Ms rc 
#$fitted{"Nb"} = 3.99
#$fitted{"Ta"} = 3.99
#$fitted{"Ti"} = 3.54 4.4
#$fitted{"Zr"} = 3.88 4.84
#$fitted{"Co"} = 3.02 or 3.8
#$fitted{"Cr"} = 3.48
#$fitted{"Fe"} = 3.46
#$fitted{"Mn"} = [10.8,0,0,0.16,2.80]; 
#$fitted{"Hf"} = 3.83 4.76
#$fitted{"Ni"} = 3.92


sub eleFit {
    my $elef = shift @_;
   return (@{$fitted{"$elef"}});
}
sub eleObj {# return properties of an element
   my $elem = shift @_;
   return (@{$element{"$elem"}});
}
sub elePso {# return properties of an element
   my $elep = shift @_;
   return (@{$pso{"$elep"}});
}

1;               # Loaded successfully
