_bom_simplify_sequence() {
	_start
	
	_messageNormal 'init: _bom_simplify'
	
	local currentFile_bom_out
	currentFile_bom_out="$safeTmp"/updated.lbom.csv
	
	echo -n > "$currentFile_bom_out"
	
	local currentLine_bom
	currentLine_bom=''
	local currentFile_bom
	currentFile_bom="$1"
	
	local currentBlock_bom
	currentBlock_bom=''
	
	local current_multiplier
	current_multiplier='0'
	
	
	# WARNING: Changes default bash pattern matching behavior.
	#shopt -s nocasematch
	
	while read currentLine_bom
	do
		_messagePlain_nominal 'read: currentLine_bom'
		_messagePlain_probe_var currentLine_bom
		
		if [[ $(_safeEcho "$currentLine_bom" | tr -dc ',' | wc -c) -lt '3' ]]
		then
			_messagePlain_bad 'bad: invalid: insufficient fields'
			_messagePlain_nominal 'ignore: line: invalid'
			#_safeEcho_newline "$currentLine_bom" >> "$currentFile_bom_out"
			continue
		fi
		
		bom_item=$(echo "$currentLine_bom" | cut -d ',' -f1)
		if [[ "$bom_item" == "" ]]
		then
			_messagePlain_nominal 'ignore: line: missing: item'
			#_safeEcho_newline "$currentLine_bom" >> "$currentFile_bom_out"
			continue
		fi
		
		_messagePlain_nominal 'read: ITEM/BUNDLE'
		bom_item=$(echo "$currentLine_bom" | cut -d ',' -f1)
		bom_dstpn=$(echo "$currentLine_bom" | cut -d ',' -f2)
		bom_mult=$(echo "$currentLine_bom" | cut -d ',' -f3 | tr -dc '0-9')
		#	bom_mult='0'
		bom_qty=$(echo "$currentLine_bom" | cut -d ',' -f4 | tr -dc '0-9')
			[[ "$bom_qty" == "" ]] && bom_qty='0'
			#bom_qty='0'
		bom_dst=$(echo "$currentLine_bom" | cut -d ',' -f5)
		bom_mark=$(echo "$currentLine_bom" | cut -d ',' -f6)
		bom_provider=$(echo "$currentLine_bom" | cut -d ',' -f7)
		bom_path=$(echo "$currentLine_bom" | cut -d ',' -f8)
		
		bom_extra=$(echo "$currentLine_bom" | cut -d ',' -f9-)
		
		_messagePlain_nominal 'write: line: simplified'
		[[ "$bom_extra" != "" ]] && bom_extra=','"$bom_extra"
		_messagePlain_probe "$bom_dstpn","$bom_mult","$bom_dst","$bom_mark","$bom_provider"
		_safeEcho_newline "$bom_dstpn","$bom_mult","$bom_dst","$bom_mark","$bom_provider" >> "$currentFile_bom_out"
		
		
	done < "$currentFile_bom"
	
	
	# WARNING: May not restore user set bash pattern matching behavior.
	#shopt -u nocasematch
	
	#bundle,dstpn,mult,qty,dst,mark,provider,path
	#item,dstpn,mult,qty,dst,mark,provider,path
	# Subsequent fields may include (typically accounted for by 'bom_extra')...
	#refdes footprint value description cost device mfr mfrpn dst dstpn link link_page supplier sbapn kitting kitting_d Xpos Ypos rot side
	unset bom_bundle
	unset bom_item bom_dstpn bom_mult bom_qty bom_dst bom_mark bom_provider bom_path
	unset refdes footprint value description cost device mfr mfrpn dst dstpn link link_page supplier sbapn kitting kitting_d Xpos Ypos rot side
	
	
	cp "$currentFile_bom_out" "$2"
	
	_stop
}


_bom_simplify() {
	"$scriptAbsoluteLocation" _bom_simplify_sequence "$@"
}

