#!"C:/xampp/perl/bin/perl.exe"
use strict;
use warnings;
use CGI;

my $cgi = CGI->new;

my $operacion = $cgi->param('operacion');
my $accion = $cgi->param('accion');
my $calcular = $cgi->param('submit');
my $controlR = $cgi->param('controlR');

unless ($calcular){
    if ($operacion eq "0" || $controlR) {
        $operacion = "";
        $controlR = "";
    }

    if ($accion eq "AC") {
        $operacion = "0";
    } else {
        $operacion .= $accion;
    }
} else {
    $operacion =~ s/×/*/g;
    $operacion =~ s/÷/\//g;
    $operacion = "(".$operacion.")";
    
    while ($operacion =~ /\(([^()]+)\)/) {
        my $expresion = $1;
        my $resultado = $expresion;
        $resultado =~ s/--/+/g;
        $resultado =~ s/(?<=\d)-(?=\d)/+-/g;
        $resultado = resolver($resultado);
        $operacion =~ s/\Q($expresion)\E/$resultado/g;
    }
}

sub resolver {
    my $operacion = $_[0];
    $operacion =~ s/%/\/100/g;
    
    while ($operacion =~ /([-]?\d*\.?\d+)\s*([*\/])\s*([-]?\d*\.?\d+)/ 
            || $operacion =~ /([-]?\d*\.?\d+)\s*([+])\s*([-]?\d*\.?\d+)/) {
        my $operando1 = $1;
        my $operador = $2;
        my $operando2 = $3;
        my $expresion = $1.$2.$3;

        my $resultado;
        if ($operador eq '*') {
            $resultado = $operando1 * $operando2;
        } elsif ($operador eq '/') {
            if ($operando2 != 0) {
                $resultado = $operando1 / $operando2;
            } else {
                return "Error: División por cero";
            }
        } elsif ($operador eq '+') {
            $resultado = $operando1 + $operando2;
        }
        $operacion =~ s/\Q$expresion/$resultado/g;
    }
    
    return $operacion;
}

open my $archivoHTML, '<', '../htdocs/Calculadora.html';
my @archivoHTML = <$archivoHTML>;
close $archivoHTML;

for my $line (@archivoHTML) {
    if ($line =~ /<input type="text" name="operacion" value='/) {
        $line =~ s/(<input type="text" name="operacion" value=')\S*('>)/$1$operacion$2/;
    } elsif ($line =~ /<input type="hidden" name="controlR" value='/) {
        $line =~ s/(<input type="hidden" name="controlR" value=')\S*('>)/$1$controlR$2/;
    }
}


open my $archivoHTML, '>', '../htdocs/Calculadora.html';
print $archivoHTML @archivoHTML;
close $archivoHTML;


print $cgi->redirect('http://localhost/Calculadora.html');