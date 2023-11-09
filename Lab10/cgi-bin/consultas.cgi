#!"C:/xampp/perl/bin/perl.exe"
use Encode qw(decode);
#use CGI;
use CGI ':standard';

my $cgi = CGI->new;

my $nombre = decode('UTF-8', $cgi->param('nombreU'));
my $periodo = $cgi->param('periodoL');
my $departamento = decode('UTF-8', $cgi->param('departamentoL'));
my $denominacion = decode('UTF-8', $cgi->param('denominacionP'));

my $archivo;
open($archivo, "Programas_de_Universidades.csv");

#print "Content-Type: text/html\n\n";
my $line;
my $aja;
while ($line = <$archivo>) {
    my @campos = $line =~ /([^|]+)/g;
    if ($campos[1] eq $nombre && $campos[4] eq $periodo && $campos[10] eq $departamento && $campos[16] eq $denominacion) {
        $aja = $line."<br>";
        #print $line."<br>";
    }
}

close($archivo);

print header,
start_html(
    -title => $nombre,
    -style => { -src => '../htdocs/consultas.css' },
),

h1("Resultados"),
      h3("Se encontraron los siguientes registros"),
      h4(
          table(
              Tr(td($aja))
          )
      ),
end_html;