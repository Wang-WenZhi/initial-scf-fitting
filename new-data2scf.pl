use strict;
use warnings;
use Cwd;
use JSON::PP;
use List::Util qw(min max);
use POSIX;
use lib '.';
use HEA;
use Expect;
use Data::Dumper;
my $currentPath = getcwd();
my $user = "zhi";

my $slurmbatch = "186.sh"; #slurm filename
my $QE_path = "/opt/QEGCC_MPICH3.4.2/bin/pw.x";
my @cp_path = `find $currentPath/CrCuNiSiZn-fitting -maxdepth 1 -type d -name "*"`;
# my @cp_path = split("\n", $cp_path);
# @cp_path = sort @cp_path;
# my $cp_paths = `find $currentPath/CrCuNiSiZn-fitting -maxdepth 2  -name "*.sout"`;
# my @cp_paths = split("\n", $cp_paths);
# @cp_paths = sort @cp_paths;
# print "$cp_paths";
# my @cp_pathpath = map (($_ =~ m/(.*)\/.*.$/gm),@cp_path);
# my @cp_pathname = map (($_ =~ m/.*\/(.*)./gm),@cp_path);
# print "@cp_pathpath\n";
# print "@cp_pathname\n";
#my @cp_path = `ls $currentPath/Cu-scf`;
#my @initial_data = `ls $currentPath/Cu-scf`;
# print @cp_path;
#print @initial_data;
chomp @cp_path;
#chomp @initial_data;
#my $cp_path = "/home/zhi/Deep-single-scf/Ge-single/Ge-mp-32"; #the path where the data at;the last '/' should be deleate 
# `cp $cp_path/ori.in SCF.in`;

my $optbatch = "SCF.in";



my @myelement = sort ("Cr","Cu","Ni","Si","Zn");#,"Cu","Ni","Si","Zn"
my $myelement = join ('',@myelement);
my $types = @myelement;



# my @myelement = sort ("Cr","Cu","Ni","Si","Zn");
# my $myelement = join ('',@myelement);
# my $types = @myelement;


my $cal = "scf";
my $nstep = 100;
my $ibrav = 0;
my $cleanall = "no";
#chdir("/home/zhi/Deep-single-scf/Ag-opt/Opt-f110-Ag/");
#my @sout = `cat kpoints.dat`;
#my @totalkpoint = grep {if(m/(\d*\s+\d*\s+\d*\s+\d*\s+\d*\s+\d*)/gm){$_ = $1;}} @sout;
#print @totalkpoint;
#my $kpoints = @totalkpoint;
#chdir("/home/zhi/Deep-single-scf/");

my $tprnfor = "tprnfor = .true.";
my $tstress = "tstress = .true.";








my %HEA;
my %myelement;
my %ele;
my %pm;
my @rho_cutoff;
my @cutoff;
#my $initial_data = @initial_data;
#######  json  ######
my $json;
{
    local $/ = undef;
    open my $fh, '<', '/opt/QEpot/SSSP_efficiency.json';
    $json = <$fh>;
    close $fh;
}
my $decoded = decode_json($json);

#######  HEA.pm  ######
for(0..$#myelement){
    $myelement{$_+1} = $myelement[$_];
    $HEA{"$myelement[$_]"}{type} = $_+1;
}
for (@myelement){
    @{$pm{$_}} = &HEA::eleObj("$_"); 
    $HEA{"$_"}{rho_cutoff} = $decoded -> {$_}->{rho_cutoff};
    $HEA{"$_"}{cutoff} = $decoded -> {$_} -> {cutoff};
    $HEA{"$_"}{jsonname} = $decoded->{$_}->{filename};
    $HEA{"$_"}{mass} = ${$pm{$_}}[2];
    $HEA{"$_"}{magn} = 0.0;

    push @rho_cutoff, $HEA{"$_"}{rho_cutoff};
    push @cutoff, $HEA{"$_"}{cutoff};
}

    my $rho_cutoff = max(@rho_cutoff);
    my $cutoff = max(@cutoff);

`sed -i 's:^calculation.*:calculation = "$cal":' $currentPath/$optbatch`;
`sed -i 's:^nstep.*:nstep = $nstep:' $currentPath/$optbatch`;
`sed -i 's:^ibrav.*:ibrav = $ibrav:' $currentPath/$optbatch`;
`sed -i '/ATOMIC_SPECIES/,/ATOMIC_POSITIONS.*/{/ATOMIC_SPECIES/!{/ATOMIC_POSITIONS.*/!d}}' $currentPath/$optbatch`;
`sed -i '/ATOMIC_POSITIONS.*/,/CELL_PARAMETERS.*/{/ATOMIC_POSITIONS.*/!{/CELL_PARAMETERS.*/!d}}' $currentPath/$optbatch`;
`sed -i '/K_POINTS.*/,/ATOMIC_SPECIES.*/{/K_POINTS.*/!{/ATOMIC_SPECIES.*/!d}}' $currentPath/$optbatch`;
`sed -i '/CELL_PARAMETERS.*/,/!End/{/CELL_PARAMETERS.*/!{/!End/!d}}' $currentPath/$optbatch`;
`sed -i '/nspin = 2/,/!systemend/{/nspin = 2/!{/!systemend/!d}}' $currentPath/$optbatch`;



my @element = $myelement;



#for my $initial_data(@initial_data){
for my $cp_path(@cp_path){
    my @datafile = sort `find $cp_path  -maxdepth 1 -name "scale_*-*.data"`;
    chomp @datafile;
    CIF:{
        for my $id (0..$#datafile){
        my ($data_path) = $datafile[$id] =~ (m/(.*)\/.*.data/);
        my ($data_num) = $datafile[$id] =~ (m/.*\/(.*)\/.*.data/);
        my ($data_name) = $datafile[$id] =~ (m/.*\/(.*).data/);
        my ($data_folder) = $datafile[$id] =~ (m/.*\/(scale_.*)-.*.data/); 
        my ($data_ele) = $datafile[$id] =~ (m/.*\/.*\/(.*)\/.*.data/); 
        my @ele = $data_ele =~/([A-Z]{1}[a-z]{0,1})/gm;
        # print "@ele";
        my $prefix = "$data_path/$data_name";
        my $foldername = "$currentPath/$myelement/SCF/$data_num/$data_folder";


        
        &lmp2data($data_name,$prefix);
        `mkdir -p $foldername`; 
        `cp $currentPath/$optbatch $foldername/$data_name.in`;

        &setting($foldername,$data_name,$cp_path,@ele);
        #  print "$data_name\n";
         &ibrav0($foldername,$data_name,"$prefix.data",@ele);
         &slurm($foldername,$data_name);

        }
    }
}

sub lmp2data
{
    (my $ele, my $prefix) = @_;

    open my $temp ,"<$prefix.data";
    my @data =<$temp>;
    close $temp;
    
    my @ele = $ele =~/([A-Z]{1}[a-z]{0,1})/gm;
    # print "@ele";

    my $data = join ("",@data);
    #my  $regax ="xy\\s+x\\s+yz\\s+";
    #if( $data !~ /$regax/gmi) 
    #    {                                   
    #        `sed -i '/zhi.*/a 0 0 0 xy xz yz' $prefix.data`;
    #    }


    `sed -i '/Atoms .*/a \n' $prefix.data`;
}

sub setting
{
    (my $foldername ,my $prefix,my $cp_path,my @ele) = @_;
    my $elelegth = @ele;
    # print "@ele";
    
    
    ###ATOMIC_SPECIES### 
    my @eles = reverse sort (@ele);
        # for(@ele){
        # `sed -i '/ATOMIC_SPECIES/a $_  $HEA{$_}{mass}  $HEA{$_}{jsonname}' $foldername/$prefix.in`;
        # }
        for(@eles){
        `sed -i '/ATOMIC_SPECIES/a $_  $HEA{$_}{mass}  $HEA{$_}{jsonname}' $foldername/$prefix.in`;
        }
        # for(@ele){
        # `sed -i '/ATOMIC_SPECIES/a $_  $HEA{$_}{mass}  Ag_ONCV_PBE-1.0.oncvpsp.upf' $foldername/$prefix.in`;
        # }
    ##starting_magnetization###                                           
    my $magnetization = `grep -A$types  "atomic species   magnetization" $cp_path/ori.sout`;
    my @magnetization = split("\n",$magnetization);
    my %element;
        for (my $i=1; $i<=@myelement; $i++){
        my $r = $i-1;
        $element{$myelement[$r]} = $i;
        }
        # print"$i";
        for(0..$#magnetization-$types) {
        my @Aftermagnetization = $magnetization[-$_];
        for(@Aftermagnetization){
            if($_ =~ m/(\w+)\s+([+-]?[0-9]+.[0-9]+)/gm)
            {  
                `sed -i '/nspin = 2/a starting_magnetization($element{$1}) = $2' $foldername/$prefix.in`;         
            }
        }   
    } 
    ### cutoff ###
        `sed -i 's:^ecutwfc.*:ecutwfc = $cutoff:' $foldername/$prefix.in`;
        `sed -i 's:^ecutrho.*:ecutrho = $rho_cutoff:' $foldername/$prefix.in`;    
    ###type###
        `sed -i 's:^ntyp.*:ntyp = $elelegth:' $foldername/$prefix.in`;

    ### Kpoints ###-----------------------------------------------------------------------------
   
    chdir("$cp_path");
    # print "$cp_path";
    my @sout = `cat kpoints.dat`;
    my @totalkpoint = grep {if(m/(\d*\s+\d*\s+\d*\s+\d*\s+\d*\s+\d*)/gm){$_ = $1;}} @sout;
    #print @totalkpoint;
    my $kpoints = @totalkpoint;
    `sed -i '/K_POINTS.*/a @totalkpoint' $foldername/$prefix.in`;
    # print @totalkpoint;
    chdir("$currentPath");
    # chdir("$cp_path");
    # my @orisout = `cat ori.sout`;
    # my @totalelements = grep {if(m/^\s+([A-Z]{1}[a-z]{0,1})\s+\d*.\d*\d*\s+\d*.\d*\s+[A-Z]{1}[a-z]{0,1}\(\d*\s+\d*.\d*\)$/gm){$_ = $1;}} @orisout;
    # #print @totalkpoint;
    # # my $totalelements = @totalelements;
    # # print"@totalelements";
    # # print @totalkpoint;
    # chdir("$currentPath");

    ### tstress tprnfor ###--------------------------------------------------------------------
    `sed -i '/nstep.*/a $tstress' $foldername/$prefix.in`;
    `sed -i '/nstep.*/a $tprnfor' $foldername/$prefix.in`;
    ### cp ###
    `cp $cp_path/dpE2expE.dat $foldername/dpE2expE.dat`;
    `cp $cp_path/elements.dat $foldername/elements.dat`;
    `cp $cp_path/kpoints.dat $foldername/kpoints.dat`;
    # print  "$cp_path";
}

sub ibrav0
{
    (my $foldername , my $prefix , my $data ,my @ele  ) = @_;
    # print "@ele";


    # my $ele = join ('',@ele);
    # my %ele;
    # for (my $ii=1; $ii<=@ele; $ii++){
    # my $rr = $ii-1;
    # $ele{$ele[$rr]}= $ii;
    # print "$ii";
    # } ###If DPGEN element*N


  
    open my $temp ,"< $data";
    my @data =<$temp>;
    close $temp;
    # print "@ele";
    my @myelements = sort @ele;
    my $myelements = join ('',@myelements);
    # my @myelementss = split("\n",$myelements);
    my %elements;
    for (my $ii=1; $ii<=@myelements; $ii++){
        my $rr = $ii-1;
        $elements{$myelements[$rr]} = $ii;
        # print"!!$myelements[$rr]";
        }

    # print "@myelementss\n";
    
    `sed -i 's:ATOMIC_POSITIONS.*:ATOMIC_POSITIONS {angstrom}:' $foldername/$prefix.in`;
    `sed -i 's:CELL_PARAMETERS.*:CELL_PARAMETERS {angstrom}:' $foldername/$prefix.in`;
    my $atoms;
    my $move;
    my $lx;
    my $ly;
    my $lz; 
    my $xy = 0;
    my $xz = 0;
    my $yz = 0;

    for(@data){
        # print "@data";
    ###atoms###
        if(m/(\d+)\s+atoms/s){ 
        $atoms = $1;
        `sed -i 's:^nat.*:nat = $1:' $foldername/$prefix.in`;
        }
    ###CELL_PARAMETERS###
        if(m/(\-?\d*\.*\d*\w*[+-]?\d*)\s+\-?\d*\.*\d*\w*[+-]?\d*\s+xlo/s){
            $move = $1;
        }
    }
    for (@data){       

        ###### xlo #######
        ### 0.0 2.84708541500004 xlo xhi
        if(m/(\-?\d*\.*\d*\w*[+-]?\d*)\s+(\-?\d*\.*\d*\w*[+-]?\d*)\s+xlo/s){
            $lx = $2-$1;
        }
        ###### ylo #######
        ### 0.0 2.847085238 ylo yhi
        if(m/(\-?\d*\.*\d*\w*[+-]?\d*)\s+(\-?\d*\.*\d*\w*[+-]?\d*)\s+ylo/s){
            $ly = $2-$1;
        }
        ###### zlo #######
        ### 0.0 2.84708568799983 zlo zhi
        if(m/(\-?\d*\.*\d*\w*[+-]?\d*)\s+(\-?\d*\.*\d*\w*[+-]?\d*)\s+zlo/s){
            $lz = $2-$1;
        }
        ###### xy xz yz #######
        ### -2.65999959883181e-07 9.26000039313875e-07 5.16000064963272e-07 xy xz yz
        if(m/(\-?\d*\.*\d*\w*[+-]?\d*)\s+(\-?\d*\.*\d*\w*\+?-?\d*)\s+(\-?\d*\.*\d*\w*[+-]?\d*)\s+xy\s+xz\s+yz/s){
            $xy = $1;
            $xz = $2;
            $yz = $3;
        }

    # ###ATOMIC_POSITION###
   

        if(m/\d+\s+(\d+)\s+(\-?\d*.?\d*e*[+-]*\d*)\s+(\-?\d*.?\d*e*[+-]*\d*)\s+(\-?\d*.?\d*e*[+-]*\d*)\s?-?\d?\s?-?\d?\s?-?\d?$/gm) #coord
        {   
    #     #     my $ele = join ('',@ele);
    #         # print "$ele";
    #     #     my @ele = split("\n",$ele);
    #     #     @ele =  sort @ele;
    #     #     my %ele;
    #     #     for (my $is=1; $is<=@ele; $is++){
    #     #     my $rs = $is-1;
    #     #     $ele{$ele[$rs]} = $is;
    #     #     }
    #     #     # print "$is";
    #     #     #  print "$ele[$rs]";
    #     # #    print "!!@ele";
            my $movex = $2 - $move;
            my $movey = $3 - $move;
            my $movez = $4 - $move; 
    
        `sed -i '/ATOMIC_POSITIONS {angstrom}/a $myelement{$1} $movex $movey $movez' $foldername/$prefix.in` ;

        

    }

    }
    
        
        # my @coord = grep {if(m/\d+\s+(\d+)\s+(\-?\d*.?\d*e*[+-]*\d*)\s+(\-?\d*.?\d*e*[+-]*\d*)\s+(\-?\d*.?\d*e*[+-]*\d*)\s?-?\d?\s?-?\d?\s?-?\d?$/gm){
        # $_ = [$1]; 
        # # my $ele = join ('',@ele);
        # my $movex = $2 - $move;
        # my $movey = $3 - $move;
        # my $movez = $4 - $move; 
        # for(0..$#data){
        # `sed -i '/ATOMIC_POSITIONS {angstrom}/a $elements{$1} $movex $movey $movez' $foldername/$prefix.in` ;
        # }
        # }}  @data;
        
        `sed -i '/CELL_PARAMETERS {angstrom}/a  $xz $yz $lz' $foldername/$prefix.in` ;
        `sed -i '/CELL_PARAMETERS {angstrom}/a  $xy $ly 0' $foldername/$prefix.in` ;
        `sed -i '/CELL_PARAMETERS {angstrom}/a  $lx 0 0' $foldername/$prefix.in` ;
}
sub slurm
{
    (my $foldername ,my $prefix) = @_;
    `sed -i '/#SBATCH.*--job-name/d' $slurmbatch`;
	`sed -i '/#sed_anchor01/a #SBATCH --job-name=$prefix' $slurmbatch`;
	
	`sed -i '/#SBATCH.*--output/d' $slurmbatch`;
	`sed -i '/#sed_anchor01/a #SBATCH --output=$prefix.sout' $slurmbatch`;
	
	`sed -i '/mpiexec.*/d' $slurmbatch`;
	`sed -i '/#sed_anchor02/a mpiexec $QE_path -in $prefix.in' $slurmbatch`;
 #`sed -i '/mpiexec.* /opt/QEGCC/bin/pw.x/d' $slurmbatch`;
    `cp $slurmbatch $foldername/$prefix.sh`;
    chdir("$foldername");
    #system("sbatch $prefix.sh");
    # print qq(sbatch $foldername/$prefix.sh\n);
    chdir("$currentPath");

}