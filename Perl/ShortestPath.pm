# -----------------------------------------------------------------
# ShortestPath.pm -- Routines dealing with the algorithmic process of finding
# the shortest path to a given point on a graph.
#
# Copyright 2005 Michael Kelly (jedimike.net)
#
# This program is released under the terms of the GNU General Public
# License as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# Mon Mar 28 19:50:39 PST 2005
# -----------------------------------------------------------------

package ShortestPath;

use strict;
use warnings;

use MapGlobals;
use MapGraphics;

use GD;

# create a hash of minimum distances with Dijkstra's algorithm
# XXX: proper desc. and function header
sub find{
	my($startID, $points) = (@_);

	my($s, $v, $w);
	my $smallestIndex;
	my $connID;

	# translate the starting ID into an actual graph point
	$s = $points->{$startID};

	my @minCache = createMinCache($points);

	$s->{'Distance'} = 0;

	while(1){
		# find the index of the smallest unknown vertex
		$smallestIndex = smallestUnknown(\@minCache);

		if( !defined($smallestIndex) ){
			last;
		}

		# assign $v to the smallest unknown vertex, and set known = true
		$v = $minCache[$smallestIndex];
		$v->{'Known'} = TRUE;

		# indicate in @minCache that the element at $smallestIndex is no longer
		# unknown by removing it from the array
		splice(@minCache, $smallestIndex, 1);

		# loop over all points adjacent to $v
		for $connID ( keys %{$v->{'Connections'}} ){
			# assign the adjacent point to $w
			$w = $points->{$connID};

			#XXX: print STDERR "Adjacent node ID: $connID\n";

			# if $w hasn't been visited yet
			if( !$w->{'Known'} ){
				
				# if v's distance + the distance between v and w is less
				# than w's distance
				if($v->{'Distance'} + $v->{'Connections'}{$connID}{'Weight'} <
					$w->{'Distance'})
				{
					# we've found a lower distance, so update w's distance
					$w->{'Distance'} =
						$v->{'Distance'}
						+ $v->{'Connections'}{$connID}{'Weight'};

					# indicate where we got this path
					$w->{'From'} = $v;
				}
			}

		}

	}
}

# given a cache of unknown vertices, find the smallest one
# TODO: add check for "not-a-through-street" flag on locations, 
# don't visit them, UNLESS they are the start node.
# XXX: proper desc. and function header
sub smallestUnknown{
	my($minCache) = (@_);
	my $minDist = INFINITY;
	my $minIndex = undef;

	# loop through every item in the passed-in points arrayref
	for (my $i = 0; $i < @$minCache; $i++){
		# if the item at this index has a smaller distance than the stored
		# smallest distance, update the smallest distance
		if($minCache->[$i]{'Distance'} < $minDist){
			$minDist = $minCache->[$i]{'Distance'};
			$minIndex = $i;
		}
	}

	# return the smallest distance
	return $minIndex;
}

# create an initial hash of minimum distances
# XXX: proper desc. and function header
sub createMinCache{
	my($points) = (@_);

	# copy the values of the given hashref: we know each of these is itself
	# a hashref, so we can directly access each point
	my $i = 0;

	return (values %$points);
}

# given a data structure populated by shortestPath(), find the shortest
# path to a given point ID.
# XXX: proper desc. and function header
sub pathTo{
	my $points = shift;
	my $target = shift;
	my $str = shift || '';
	
	if( defined($target->{'From'}{'ID'}) ){
		$str .= pathTo($points, $target->{'From'});
		$str .= " to ";
	}
	$str .= "$target->{'ID'}";
	return $str;
}

# write the path to a given target point, given a hashref of post-Dijkstra
# points, a hashref of edges, a GD image to draw to, and a color to draw with.
# XXX: proper desc. and function header
sub drawTo{
	my($points, $edges, $target, $im, $color, $xoff, $yoff, $w, $h, $scale) = (@_);

	# follow 'from' links until we reach the original point
	while( defined($target->{'From'}{'ID'}) ){
		MapGraphics::drawEdge(
			$edges->{$target->{'Connections'}{$target->{'From'}{'ID'}}{'EdgeID'}},
			$im, 2, $color, $xoff, $yoff, $w, $h, $scale, 1);

		# keep following the trail back to its source
		$target = $target->{'From'};
	}
}

1;
