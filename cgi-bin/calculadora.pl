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
    my @expresion = split /([+*\/%])/, $operacion;
    for (my $i = 0; $i < @expresion; $i++){
        if ($expresion[$i] eq "+"){
            $result = $expresion[$i-1]+$expresion[$i+1];
            $expresion[$i+1] = $result;
        } elsif ($expresion[$i] eq "-"){
            $result = $expresion[$i-1]-$expresion[$i+1];
            $expresion[$i+1] = $result;
        } elsif ($expresion[$i] eq "*"){
            $result = $expresion[$i-1]*$expresion[$i+1];
            $expresion[$i+1] = $result;
        } elsif ($expresion[$i] eq "/"){
            $result = $expresion[$i-1]/$expresion[$i+1];
            $expresion[$i+1] = $result;
        } elsif ($expresion[$i] eq "%"){
            $result = ($expresion[$i-1]/100);
            $expresion[$i] = $result;
        }
    }
    $operacion = $result;
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