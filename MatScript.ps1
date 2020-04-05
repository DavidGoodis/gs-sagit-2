 $a = Get-Item H:\wrk\GS\schmup1\schmup\Mesh\CubeDefaultBlue.nmm
 for($i=1;$i -lt 100; $i++) {Copy-Item $a H:\wrk\GS\schmup1\schmup\Mesh\CubeMat$i.nmm }