#!"C:/xampp/perl/bin/perl.exe"
use strict;
use warnings;
use CGI;

my $cgi = CGI->new;

my $operacion = $cgi->param('operacion');
my $accion = $cgi->param('accion');
my $calcular = $cgi->param('submit');

unless ($calcular){
    if ($operacion eq "0") {
        $operacion = "";
    }

    if ($accion eq "AC") {
        $operacion = "0";
    } else {
        $operacion .= $accion;
    }
} else {
    $operacion = resolverP($operacion);
    $operacion = resolverMD($operacion);
    $operacion = resolverSR($operacion);
}

sub resolverP {
    my $result;
    my $operacion = $_[0];
    my @expresion = split /([+*\/%])/, $operacion;
    for (my $i = 0; $i < @expresion; $i++){
        if ($expresion[$i] eq "%"){
            $result = ($expresion[$i-1]/100);
            $expresion[$i] = $result;
            $expresion[$i-1] = "";
        }
    }
    $operacion = "";
    for (my $i = 0; $i < @expresion; $i++){
        $operacion .= $expresion[$i];
    }
    return $operacion;
}
sub resolverMD {
    my $result;
    my $operacion = $_[0];
    my @expresion = split /([+*\/])/, $operacion;
    for (my $i = 0; $i < @expresion; $i++){
        if ($expresion[$i] eq "*"){
            $result = $expresion[$i-1]*$expresion[$i+1];
            $expresion[$i+1] = $result;
            $expresion[$i-1] = "";
            $expresion[$i] = "";
        } elsif ($expresion[$i] eq "/"){
            $result = $expresion[$i-1]/$expresion[$i+1];
            $expresion[$i+1] = $result;
            $expresion[$i-1] = "";
            $expresion[$i] = "";
        }
    }
    $operacion = "";
    for (my $i = 0; $i < @expresion; $i++){
        $operacion .= $expresion[$i];
    }
    return $operacion;
}
sub resolverSR {
    my $result;
    my $operacion = $_[0];
    my @expresion = split /([+])/, $operacion;
    for (my $i = 0; $i < @expresion; $i++){
        if ($expresion[$i] eq "+"){
            $result = $expresion[$i-1]+$expresion[$i+1];
            $expresion[$i+1] = $result;
            $expresion[$i-1] = "";
            $expresion[$i] = "";
        }
        if ($expresion[$i] eq "-"){
            $result = $expresion[$i-1]-$expresion[$i+1];
            $expresion[$i+1] = $result;
            $expresion[$i-1] = "";
            $expresion[$i] = "";
        }
    }
    $operacion = "";
    for (my $i = 0; $i < @expresion; $i++){
        $operacion .= $expresion[$i];
    }
    return $operacion;
}

open my $archivoHTML, '<', '../htdocs/Calculadora.html';
my @archivoHTML = <$archivoHTML>;
close $html_file;

for my $line (@archivoHTML) {
    if ($line =~ /<input type="text" name="operacion" value='/) {
        $line =~ s/(<input type="text" name="operacion" value=')\S*('>)/$1$operacion$2/;
    }
}


open my $archivoHTML, '>', '../htdocs/Calculadora.html';
print $archivoHTML @archivoHTML;
close $archivoHTML;


print $cgi->redirect('http://localhost/Calculadora.html');