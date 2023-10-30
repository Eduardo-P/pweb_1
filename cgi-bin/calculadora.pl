#!"C:/xampp/perl/bin/perl.exe"
use strict;
use warnings;
use CGI;

my $cgi = CGI->new;

my $operacion = $cgi->param('operacion');   # recibe el valor del TextBox
my $accion = $cgi->param('accion');         # recibe el valor de cualquier botón a excepción del “=”
my $calcular = $cgi->param('submit');       # recibe el valor del botón “=” para calcular
my $controlR = $cgi->param('controlR');     # recibe el valor de un input tipo hidden, sirve para controlar si el usuario hizo clic en el botón “=”

unless ($calcular){
    # Si $operacion es igual a "0" o igual a "Error:_División_por_cero" o si $controlR tiene un valor verdadero y $accion contiene al menos un número, un punto o un paréntesis, entonces se borra el contenido de la variable $operacion
    if ($operacion eq "0" || $operacion eq "Error:_División_por_cero" || ($controlR && $accion =~ /[0-9.()]/)) {
        $operacion = "";
    }
    $controlR = "";     # La variable $controlR se borra

    if ($accion eq "AC") {      # El botón de “AC” borra todo lo ingresado en el TextBox y muestra el valor inicial “0”
        $operacion = "0";
    } else {
        $operacion .= $accion;  # Se concatenan los valores ingresados por el usuario
    }
} else {
    $controlR = "activo";
    $operacion =~ s/×/*/g;  # Los caracteres × son cambiados por *
    $operacion =~ s/÷/\//g; # Los caracteres ÷ son cambiados por /
    $operacion = "(".$operacion.")";

    while ($operacion =~ /\(([^()]+)\)/) {  # Expresión regular que busca coincidencias de paréntesis que contengan caracteres que no sean paréntesis
        my $expresion = $1;
        my $resultado = $expresion;
        $resultado =~ s/--/+/g;     # Busca todas las instancias de "--" y las reemplaza por "+".
        $resultado =~ s/(?<=\d)-(?=\d)/+-/g;    # Busca un guion (-) que esté rodeado por dígitos y lo reemplaza por "+-".
        $resultado = resolver($resultado);
        if ($resultado eq "Error") {
            $operacion = "Error:_División_por_cero";
            last;
        }
        $operacion =~ s/\Q($expresion)\E/$resultado/g;  # Busca en la cadena $operacion una expresión igual a lo que contiene la variable $expresion y la reemplaza por el contenido de la variable $resultado
    }
}

sub resolver {
    my $operacion = $_[0];
    $operacion =~ s/%/\/100/g;  # Busca el carácter "%" y lo reemplaza con la cadena "/100"
    
    while ($operacion =~ /([-]?\d*\.?\d+)\s*([*\/])\s*([-]?\d*\.?\d+)/          # Busca la primera ocurrencia de un patrón que consta de un número (positivo o negativo) seguido de un operador ("*" o "/") y al final otro número
            || $operacion =~ /([-]?\d*\.?\d+)\s*([+])\s*([-]?\d*\.?\d+)/) {     # Busca la primera ocurrencia y usa un patron parecido al anterior, con la diferencia de que buscara el operador "+""
        my $operando1 = $1;     # Se asigna el primer operando capturado
        my $operador = $2;      # Se asigna el operador capturado
        my $operando2 = $3;     # Se asigna el segundo operando capturado
        my $expresion = $1.$2.$3;

        my $resultado;
        if ($operador eq '*') {
            $resultado = $operando1 * $operando2;       # Se realiza la multiplicación
        } elsif ($operador eq '/') {
            if ($operando2 != 0) {
                $resultado = $operando1 / $operando2;   # Se realiza la división
            } else {
                return "Error";
            }
        } elsif ($operador eq '+') {
            $resultado = $operando1 + $operando2;       # Se realiza la adición
        }
        $operacion =~ s/\Q$expresion/$resultado/g;      # Busca en la cadena $operacion una expresión igual a lo que contiene la variable $expresion y la reemplaza por el contenido de la variable $resultado
    }
    return $operacion;
}

open my $archivoHTML, '<', '../htdocs/Calculadora.html';    # Se abre el archivo "Calculadora.html" en modo de lectura
my @archivoHTML = <$archivoHTML>;   # Cada línea del archivo se almacena como un elemento del array
close $archivoHTML;

for my $line (@archivoHTML) {
    if ($line =~ /<input type="text" name="operacion" value='/) {       # Busca la línea dentro del archivo HTML que hace referencia al TextBox del formulario
        $line =~ s/(<input type="text" name="operacion" value=')\S*('>)/$1$operacion$2/;    # Actualiza/reemplaza el valor del TextBox por el contenido de la variable $operacion
    } elsif ($line =~ /<input type="hidden" name="controlR" value='/) {     # Busca la línea dentro del archivo HTML que hace referencia al hidden del formulario
        $line =~ s/(<input type="hidden" name="controlR" value=')\S*('>)/$1$controlR$2/;    # Actualiza/reemplaza el valor del hidden por el contenido de la variable $controlR
    }
}

open my $archivoHTML, '>', '../htdocs/Calculadora.html';    # Se abre nuevamente el archivo "Calculadora.html" en modo de escritura
print $archivoHTML @archivoHTML;    # El contenido modificado del archivo, almacenado en @archivoHTML, se imprime de nuevo en el archivo
close $archivoHTML;

print $cgi->redirect('http://localhost/Calculadora.html');  # Se redirecciona a la misma página Web local