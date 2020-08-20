_bom_update_sequence() {
	_start
	
	_messageNormal 'init: _bom_update'
	
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
		
		if _safeEcho "$currentLine_bom" | grep -i '###.*-magic-.*###' > /dev/null 2>&1
		then
			_safeEcho "$currentLine_bom" | grep -i '###.*-magic-stop###' > /dev/null 2>&1 && currentBlock_bom='stop'
			_safeEcho "$currentLine_bom" | grep -i '###COMMENTS-magic-START###' > /dev/null 2>&1 && currentBlock_bom='COMMENTS'
			_safeEcho "$currentLine_bom" | grep -i '###MULTIPLIER-magic-START###' > /dev/null 2>&1 && currentBlock_bom='MULTIPLIER'
			_safeEcho "$currentLine_bom" | grep -i '###BUNDLE-magic-START###' > /dev/null 2>&1 && currentBlock_bom='BUNDLE'
			_safeEcho "$currentLine_bom" | grep -i '###ITEM-magic-START###' > /dev/null 2>&1 && currentBlock_bom='ITEM'
			_messagePlain_good 'found: magic: '"$currentBlock_bom"
			
			_messagePlain_nominal 'write: line: magic'
			_safeEcho_newline "$currentLine_bom" >> "$currentFile_bom_out"
			continue
		fi
		
		if [[ "$currentLine_bom" == "" ]]
		then
			#_messagePlain_nominal 'ignore: line: empty'
			_messagePlain_nominal 'write: line: empty'
			_safeEcho_newline "$currentLine_bom_override" >> "$currentFile_bom_out"
			continue
		fi
		if [[ $(_safeEcho "$currentLine_bom" | head -c1 | tr -dc '#') == '#' ]]
		then
			_messagePlain_nominal 'write: line: comment'
			_safeEcho_newline "$currentLine_bom" >> "$currentFile_bom_out"
			continue
		fi
		
		if [[ "$currentBlock_bom" == 'MULTIPLIER' ]]
		then
			_messagePlain_nominal 'read: MULTIPLIER'
			if [[ $(_safeEcho "$currentLine_bom" | tr -dc '0-9' | wc -c) -gt 0 ]]
			then
				current_multiplier=$(_safeEcho "$currentLine_bom" | tr -dc '0-9')
				_messagePlain_good 'found: MULTIPLIER: '"$current_multiplier"
			else
				_messagePlain_bad 'missing: MULTIPLIER'
			fi
		fi
		
		
		bom_item=$(echo "$currentLine_bom" | cut -d ',' -f1)
		if ( [[ "$currentBlock_bom" == 'BUNDLE' ]] || [[ "$currentBlock_bom" == 'ITEM' ]] ) && [[ "$bom_item" != "" ]]
		then
			if [[ $(_safeEcho "$currentLine_bom" | tr -dc ',' | wc -c) -lt '3' ]]
			then
				_messagePlain_bad 'bad: invalid: insufficient fields'
				_messagePlain_nominal 'write: line: invalid'
				_safeEcho_newline "$currentLine_bom" >> "$currentFile_bom_out"
				continue
			fi
			
			_messagePlain_nominal 'read: ITEM/BUNDLE'
			
			bom_item=$(echo "$currentLine_bom" | cut -d ',' -f1)
			bom_dstpn=$(echo "$currentLine_bom" | cut -d ',' -f2)
			#bom_mult=$(echo "$currentLine_bom" | cut -d ',' -f3 | tr -dc '0-9')
			 bom_mult='0'
			bom_qty=$(echo "$currentLine_bom" | cut -d ',' -f4 | tr -dc '0-9')
			 [[ "$bom_qty" == "" ]] && bom_qty='0'
			 #bom_qty='0'
			bom_dst=$(echo "$currentLine_bom" | cut -d ',' -f5)
			bom_mark=$(echo "$currentLine_bom" | cut -d ',' -f6)
			bom_provider=$(echo "$currentLine_bom" | cut -d ',' -f7)
			bom_path=$(echo "$currentLine_bom" | cut -d ',' -f8)
			
			bom_extra=$(echo "$currentLine_bom" | cut -d ',' -f9-)
			
			
			
			if [[ $(_safeEcho "$current_multiplier" | tr -dc '0-9') -ge 0 ]] && [[ $(_safeEcho "$bom_qty" | tr -dc '0-9') -ge 0 ]]
			then
				bom_mult=$(bc <<< "$bom_qty * $current_multiplier")
				_messagePlain_good 'determined: mult: '"$bom_mult"
			fi
			
			_messagePlain_nominal 'write: line: updated'
			[[ "$bom_extra" != "" ]] && bom_extra=','"$bom_extra"
			_messagePlain_probe "$bom_item","$bom_dstpn","$bom_mult","$bom_qty","$bom_dst","$bom_mark","$bom_provider","$bom_path""$bom_extra"
			_safeEcho_newline "$bom_item","$bom_dstpn","$bom_mult","$bom_qty","$bom_dst","$bom_mark","$bom_provider","$bom_path""$bom_extra" >> "$currentFile_bom_out"
		else
			_messagePlain_nominal 'write: line: orig'
			_safeEcho_newline "$currentLine_bom" >> "$currentFile_bom_out"
		fi
		
		
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
	
	
	cp "$currentFile_bom_out" "$currentFile_bom"
	
	_stop
}
_bom_update() {
	"$scriptAbsoluteLocation" _bom_update_sequence "$@"
}
