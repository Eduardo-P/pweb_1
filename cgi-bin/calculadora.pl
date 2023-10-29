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
    my @expresion = split /([+*\/])/, $operacion;
    for (my $i = 0; $i < @expresion; $i++){
        if ($expresion[$i] eq "*"){
            $expresion[$i+1] = $expresion[$i-1]*$expresion[$i+1];
            splice(@expresion, $i-1, 2);
            $i -= 2;
        } elsif ($expresion[$i] eq "/"){
            $expresion[$i+1] = $expresion[$i-1]/$expresion[$i+1];
            splice(@expresion, $i-1, 2);
            $i -= 2;
        }
    }
    for (my $i = 0; $i < @expresion; $i++){
        if ($expresion[$i] eq "+"){
            $expresion[$i+1] = $expresion[$i-1]+$expresion[$i+1];
            splice(@expresion, $i-1, 2);
            $i -= 2;
        }
    }
    return $expresion[0];
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