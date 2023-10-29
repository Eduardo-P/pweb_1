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
    $operacion =~ s/×/*/g;
    $operacion =~ s/÷/\//g;

    my @coincidencias = $operacion =~ /\(/g;
    for (my $i = 0; $i < @coincidencias+1; $i++){
        my $expresion = $operacion;
        if ($expresion =~ /\(([^()]+)\)/){
            $expresion = $1;
        }
        my $resultado = $expresion;
        $resultado =~ s/--/+/g;
        $resultado =~ s/(?<=\d)-(?=\d)/+-/g;
        $resultado = resolver($resultado);
        if ($i < @coincidencias){
            $expresion = "(".$expresion.")";
        }
        $operacion =~ s/\Q$expresion\E/$resultado/g;
    }
}

sub resolver {
    my $operacion = $_[0];
    $operacion =~ s/%/\/100/g;

    my @coincidencias = $operacion =~ /[\*\/]/g;
    for (my $i = 0; $i < @coincidencias; $i++){
        if ($operacion =~ /([-]?\d*\.?\d+)\s*([*\/])\s*([-]?\d*\.?\d+)/){
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
            }
            $operacion =~ s/\Q$expresion\E/$resultado/g;
        }
    }
    my @coincidencias = $operacion =~ /[+]/g;
    for (my $i = 0; $i < @coincidencias; $i++){
        if ($operacion =~ /([-]?\d*\.?\d+)\s*([+])\s*([-]?\d*\.?\d+)/){
            my $operando1 = $1;
            my $operador = $2;
            my $operando2 = $3;
            my $expresion = $1.$2.$3;

            my $resultado;
            if ($operador eq '+') {
                $resultado = $operando1 + $operando2;
            }
            $operacion =~ s/\Q$expresion\E/$resultado/g;
        }
    }
    return $operacion;
}

open my $archivoHTML, '<', '../htdocs/Calculadora.html';
my @archivoHTML = <$archivoHTML>;
close $archivoHTML;

for my $line (@archivoHTML) {
    if ($line =~ /<input type="text" name="operacion" value='/) {
        $line =~ s/(<input type="text" name="operacion" value=')\S*('>)/$1$operacion$2/;
    }
}


open my $archivoHTML, '>', '../htdocs/Calculadora.html';
print $archivoHTML @archivoHTML;
close $archivoHTML;


print $cgi->redirect('http://localhost/Calculadora.html');