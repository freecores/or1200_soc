#!/usr/bin/perl
#
#

use Getopt::Std;

getopt( 'fsdx' );

open( BIN_FILE, $opt_f ) or die "Can't open $opt_f!!!\n";

$memory_address = 0;

if( $opt_s == 32 ) {
  while ( read( BIN_FILE, $buf, 4 ) ) {
    $out = unpack( "H8", $buf);
    
    if( $opt_x ) {
	    print "$out\n";	    
	  } else {
	    printf( "\@%08x\n", $memory_address );
	    print "$out\n\n";
	  }
    
    $memory_address++;
  }
} elsif( $opt_s == 16 ) {
  while ( read( BIN_FILE, $buf, 2 ) ) {
    $out = unpack( "H4", $buf);
    
    if( $opt_x ) {
	    print "$out\n";	    
	  } else {
	    printf( "\@%08x\n", $memory_address );
	    print "$out\n\n";
    }
    
    $memory_address++;
  }
} elsif( $opt_s == 8 ) {
  while ( read( BIN_FILE, $buf, 1 ) ) {
    $out = unpack( "H2", $buf);
    
    if( $opt_x ) {
	    print "$out\n";	    
	  } else {
	    printf( "\@%08x\n", $memory_address );
	    print "$out\n\n";
    }
    
    $memory_address++;
  }
} else {
    print "ERROR! $opt_s is invalad option for -s\n";
}

if( $opt_x ) {
	for ( $memory_depth = $opt_d ;$memory_depth > $memory_address; $memory_address++ ) {
	  print "0\n";
	}
}



# if( $opt_s == 32 ) {
#   for ( $memory_depth = $opt_d - 1 ;$memory_depth > $memory_address; $memory_address++ ) {
#     
#     printf( "\@%08x\n", $memory_address );
#     print "0\n\n";
#   }
# } elsif( $opt_s == 16 ) {
#   while ( read( BIN_FILE, $buf, 2 ) ) {
#     $out = unpack( "H4", $buf);
#     
#     printf( "\@%08x\n", $memory_address );
#     print "$out\n\n";
#     
#     $memory_address++;
#   }
# } elsif( $opt_s == 8 ) {
#   while ( read( BIN_FILE, $buf, 1 ) ) {
#     $out = unpack( "H2", $buf);
#     
#     printf( "\@%08x\n", $memory_address );
#     print "$out\n\n";
#     
#     $memory_address++;
#   }
# } else {
#     print "ERROR! $opt_s is invalad option for -s\n";
# }

