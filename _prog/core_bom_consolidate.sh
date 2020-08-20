_bom_consolidate_sequence() {
	_start
	
	_messageNormal 'init: _bom_consolidate'
	
	local currentFile_bom_out
	currentFile_bom_out="$safeTmp"/consolidated.lbom.csv
	
	echo -n > "$currentFile_bom_out"
	
	local currentLine_bom
	currentLine_bom=''
	local currentFile_bom
	currentFile_bom="$1"
	
	local currentBlock_bom
	currentBlock_bom=''
	
	local current_multiplier
	current_multiplier='0'
	
	local currentLine_bom_out
	local currentLine_bom_lookup
	
	local bom_item_out
	local bom_item_lookup
	
	local currentLine__duplicate
	
	
	local currentBlock_bom_lookup
	
	local bom_empty_fields_count
	local bom_empty_fields_count_lookup
	
	local bom_dstpn_lookup
	local bom_dst_lookup
	local bom_mark_lookup
	local bom_provider_lookup
	local bom_path_lookup
	local bom_extra_lookup
	
	
	local currentFile_override
	local currentLine_bom_override
	
	local bom_item_override
	local bom_dstpn_override
	local bom_dst_override
	local bom_mark_override
	local bom_provider_override
	local bom_path_override
	local bom_extra_override
	
	
	
	currentFile_override=/dev/null
	[[ "$3" != "" ]] && currentFile_override="$3"
	
	
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
			
			_messagePlain_nominal 'ignore: line: magic'
			#_messagePlain_nominal 'write: line: magic'
			#_safeEcho_newline "$currentLine_bom" >> "$currentFile_bom_out"
			continue
		fi
		
		if [[ "$currentLine_bom" == "" ]]
		then
			_messagePlain_nominal 'ignore: line: empty'
			#_messagePlain_nominal 'write: line: empty'
			#_safeEcho_newline "$currentLine_bom_override" >> "$currentFile_bom_out"
			continue
		fi
		if [[ $(_safeEcho "$currentLine_bom" | head -c1 | tr -dc '#') == '#' ]]
		then
			_messagePlain_nominal 'ignore: line: comment'
			#_messagePlain_nominal 'write: line: comment'
			#_safeEcho_newline "$currentLine_bom" >> "$currentFile_bom_out"
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
				_messagePlain_nominal 'ignore: line: invalid'
				#_messagePlain_nominal 'write: line: invalid'
				#_safeEcho_newline "$currentLine_bom" >> "$currentFile_bom_out"
				continue
			fi
			
			_messagePlain_nominal 'read: ITEM/BUNDLE'
			bom_item=$(echo "$currentLine_bom" | cut -d ',' -f1)
			bom_dstpn=$(echo "$currentLine_bom" | cut -d ',' -f2)
			#bom_mult=$(echo "$currentLine_bom" | cut -d ',' -f3 | tr -dc '0-9')
			 bom_mult='0'
			#bom_qty=$(echo "$currentLine_bom" | cut -d ',' -f4 | tr -dc '0-9')
			# [[ "$bom_qty" == "" ]] && bom_qty='0'
			  bom_qty='0'
			bom_dst=$(echo "$currentLine_bom" | cut -d ',' -f5)
			bom_mark=$(echo "$currentLine_bom" | cut -d ',' -f6)
			bom_provider=$(echo "$currentLine_bom" | cut -d ',' -f7)
			bom_path=$(echo "$currentLine_bom" | cut -d ',' -f8)
			
			bom_extra=$(echo "$currentLine_bom" | cut -d ',' -f9-)
			
			
			currentLine__duplicate='false'
			while [[ -e "$currentFile_bom_out" ]] && read currentLine_bom_out
			do
				bom_item_out=$(echo "$currentLine_bom_out" | cut -d ',' -f1)
				if [[ "$bom_item_out" == "$bom_item" ]]
				then
					_messagePlain_nominal 'ignore: line: done'
					currentLine__duplicate='true'
				fi
			done < "$currentFile_bom_out"
			[[ "$currentLine__duplicate" == 'true' ]] && continue
			
			while read currentLine_bom_lookup
			do
				if _safeEcho "$currentLine_bom_lookup" | grep -i '###.*-magic-.*###' > /dev/null 2>&1
				then
					_safeEcho "$currentLine_bom_lookup" | grep -i '###.*-magic-stop###' > /dev/null 2>&1 && currentBlock_bom_lookup='stop'
					_safeEcho "$currentLine_bom_lookup" | grep -i '###COMMENTS-magic-START###' > /dev/null 2>&1 && currentBlock_bom_lookup='COMMENTS'
					_safeEcho "$currentLine_bom_lookup" | grep -i '###MULTIPLIER-magic-START###' > /dev/null 2>&1 && currentBlock_bom_lookup='MULTIPLIER'
					_safeEcho "$currentLine_bom_lookup" | grep -i '###BUNDLE-magic-START###' > /dev/null 2>&1 && currentBlock_bom_lookup='BUNDLE'
					_safeEcho "$currentLine_bom_lookup" | grep -i '###ITEM-magic-START###' > /dev/null 2>&1 && currentBlock_bom_lookup='ITEM'
					_messagePlain_good 'found: magic: '"$currentBlock_bom_lookup"
					
					_messagePlain_nominal 'ignore: line: magic'
					#_messagePlain_nominal 'write: line: magic'
					#_safeEcho_newline "$currentLine_bom_lookup" >> "$currentFile_bom_out"
					continue
				fi
				[[ "$currentBlock_bom_lookup" == 'COMMENTS' ]] && continue
				[[ "$currentBlock_bom_lookup" == 'MULTIPLIER' ]] && continue
				
				if [[ "$currentLine_bom_lookup" == "" ]]
				then
					_messagePlain_nominal 'ignore: line: empty'
					#_messagePlain_nominal 'write: line: empty'
					#_safeEcho_newline "$currentLine_bom_override" >> "$currentFile_bom_out"
					continue
				fi
				if [[ $(_safeEcho "$currentLine_bom_lookup" | head -c1 | tr -dc '#') == '#' ]]
				then
					_messagePlain_nominal 'ignore: line: comment'
					#_messagePlain_nominal 'write: line: comment'
					#_safeEcho_newline "$currentLine_bom_lookup" >> "$currentFile_bom_out"
					continue
				fi
				
				if [[ $(_safeEcho "$currentLine_bom_lookup" | tr -dc ',' | wc -c) -lt '3' ]]
				then
					_messagePlain_bad 'bad: invalid: insufficient fields'
					_messagePlain_nominal 'ignore: line: invalid'
					#_messagePlain_nominal 'write: line: invalid'
					#_safeEcho_newline "$currentLine_bom_lookup" >> "$currentFile_bom_out"
					continue
				fi
				
				
				bom_item_lookup=$(echo "$currentLine_bom_lookup" | cut -d ',' -f1)
				[[ "$bom_item_lookup" != "$bom_item" ]] && continue
				
				bom_mult_lookup=$(echo "$currentLine_bom_lookup" | cut -d ',' -f3 | tr -dc '0-9')
				! [[ "$bom_mult" -ge 0 ]] && bom_mult='0'
				[[ "$bom_mult" == "" ]] && bom_mult='0'
				! [[ "$bom_mult_lookup" -ge 0 ]] && bom_mult_lookup='0'
				[[ "$bom_mult_lookup" == "" ]] && bom_mult_lookup='0'
				bom_mult=$(bc <<< "$bom_mult + $bom_mult_lookup")
				_messagePlain_good 'determined: mult: '"$bom_mult"
				
				bom_empty_fields_count=0
				[[ "$bom_dstpn" == "" ]] && let bom_empty_fields_count=bom_empty_fields_count+1
				[[ "$bom_dst" == "" ]] && let bom_empty_fields_count=bom_empty_fields_count+1
				[[ "$bom_mark" == "" ]] && let bom_empty_fields_count=bom_empty_fields_count+1
				[[ "$bom_provider" == "" ]] && let bom_empty_fields_count=bom_empty_fields_count+1
				[[ "$bom_path" == "" ]] && let bom_empty_fields_count=bom_empty_fields_count+1
				[[ "$bom_extra" == "" ]] && let bom_empty_fields_count=bom_empty_fields_count+1
				
				if [[ "$bom_empty_fields_count" -gt '0' ]]
				then
					bom_dstpn_lookup=$(echo "$currentLine_bom_lookup" | cut -d ',' -f2)
					bom_dst_lookup=$(echo "$currentLine_bom_lookup" | cut -d ',' -f5)
					bom_mark_lookup=$(echo "$currentLine_bom_lookup" | cut -d ',' -f6)
					bom_provider_lookup=$(echo "$currentLine_bom_lookup" | cut -d ',' -f7)
					bom_path_lookup=$(echo "$currentLine_bom_lookup" | cut -d ',' -f8)
					bom_extra_lookup=$(echo "$currentLine_bom_lookup" | cut -d ',' -f9-)
					
					bom_empty_fields_count_lookup=0
					[[ "$bom_dstpn_lookup" == "" ]] && let bom_empty_fields_count_lookup=bom_empty_fields_count_lookup+1
					[[ "$bom_dst_lookup" == "" ]] && let bom_empty_fields_count_lookup=bom_empty_fields_count_lookup+1
					[[ "$bom_mark_lookup" == "" ]] && let bom_empty_fields_count_lookup=bom_empty_fields_count_lookup+1
					[[ "$bom_provider_lookup" == "" ]] && let bom_empty_fields_count_lookup=bom_empty_fields_count_lookup+1
					[[ "$bom_path_lookup" == "" ]] && let bom_empty_fields_count_lookup=bom_empty_fields_count_lookup+1
					[[ "$bom_extra_lookup" == "" ]] && let bom_empty_fields_count_lookup=bom_empty_fields_count_lookup+1
					
					if [[ "$bom_empty_fields_count" -gt "$bom_empty_fields_count_lookup" ]]
					then
						bom_dstpn="$bom_dstpn_lookup"
						bom_dst="$bom_dst_lookup"
						bom_mark="$bom_mark_lookup"
						bom_provider="$bom_provider_lookup"
						bom_path="$bom_path_lookup"
						bom_extra="$bom_extra_lookup"
						_messagePlain_good 'determined: supplementary fields'
					fi
				fi
				
			done < "$currentFile_bom"
			
			while read currentLine_bom_override
			do
				if _safeEcho "$currentLine_bom_override" | grep -i '###.*-magic-.*###' > /dev/null 2>&1
				then
					_safeEcho "$currentLine_bom_override" | grep -i '###.*-magic-stop###' > /dev/null 2>&1 && currentBlock_bom_override='stop'
					_safeEcho "$currentLine_bom_override" | grep -i '###COMMENTS-magic-START###' > /dev/null 2>&1 && currentBlock_bom_override='COMMENTS'
					_safeEcho "$currentLine_bom_override" | grep -i '###MULTIPLIER-magic-START###' > /dev/null 2>&1 && currentBlock_bom_override='MULTIPLIER'
					_safeEcho "$currentLine_bom_override" | grep -i '###BUNDLE-magic-START###' > /dev/null 2>&1 && currentBlock_bom_override='BUNDLE'
					_safeEcho "$currentLine_bom_override" | grep -i '###ITEM-magic-START###' > /dev/null 2>&1 && currentBlock_bom_override='ITEM'
					_messagePlain_good 'found: magic: '"$currentBlock_bom_override"
					
					_messagePlain_nominal 'ignore: line: magic'
					#_messagePlain_nominal 'write: line: magic'
					#_safeEcho_newline "$currentLine_bom_override" >> "$currentFile_bom_out"
					continue
				fi
				[[ "$currentBlock_bom_override" == 'COMMENTS' ]] && continue
				[[ "$currentBlock_bom_override" == 'MULTIPLIER' ]] && continue
				
				if [[ "$currentLine_bom_override" == "" ]]
				then
					_messagePlain_nominal 'ignore: line: empty'
					#_messagePlain_nominal 'write: line: empty'
					#_safeEcho_newline "$currentLine_bom_override" >> "$currentFile_bom_out"
					continue
				fi
				if [[ $(_safeEcho "$currentLine_bom_override" | head -c1 | tr -dc '#') == '#' ]]
				then
					_messagePlain_nominal 'ignore: line: comment'
					#_messagePlain_nominal 'write: line: comment'
					#_safeEcho_newline "$currentLine_bom_override" >> "$currentFile_bom_out"
					continue
				fi
				
				if [[ $(_safeEcho "$currentLine_bom_override" | tr -dc ',' | wc -c) -lt '3' ]]
				then
					_messagePlain_bad 'bad: invalid: insufficient fields'
					_messagePlain_nominal 'ignore: line: invalid'
					#_messagePlain_nominal 'write: line: invalid'
					#_safeEcho_newline "$currentLine_bom_override" >> "$currentFile_bom_out"
					continue
				fi
				
				bom_item_override=$(echo "$currentLine_bom_override" | cut -d ',' -f1)
				[[ "$bom_item_override" != "$bom_item" ]] && continue
				
				# ATTENTION: Does not allow overrides to blank fields by default. To force blanking any available information, use a meaningless string (ie. '-' ).
				bom_dstpn_override=$(echo "$currentLine_bom_override" | cut -d ',' -f2)
				 [[ "$bom_dstpn_override" != "" ]] && bom_dstpn="$bom_dstpn_override"
				bom_dst_override=$(echo "$currentLine_bom_override" | cut -d ',' -f5)
				 [[ "$bom_dst_override" != "" ]] && bom_dst="$bom_dst_override"
				bom_mark_override=$(echo "$currentLine_bom_override" | cut -d ',' -f6)
				 [[ "$bom_mark_override" != "" ]] && bom_mark="$bom_mark_override"
				bom_provider_override=$(echo "$currentLine_bom_override" | cut -d ',' -f7)
				 [[ "$bom_provider_override" != "" ]] && bom_provider="$bom_provider_override"
				bom_path_override=$(echo "$currentLine_bom_override" | cut -d ',' -f8)
				 [[ "$bom_path_override" != "" ]] && bom_path="$bom_path_override"
				bom_extra_override=$(echo "$currentLine_bom_override" | cut -d ',' -f9-)
				 [[ "$bom_extra_override" != "" ]] && bom_extra="$bom_extra_override"
				
				
				_messagePlain_good 'determined: override fields'
				
			done < "$currentFile_override"
			
			
			_messagePlain_nominal 'write: line: consolidated'
			[[ "$bom_extra" != "" ]] && bom_extra=','"$bom_extra"
			_messagePlain_probe "$bom_item","$bom_dstpn","$bom_mult","$bom_qty","$bom_dst","$bom_mark","$bom_provider","$bom_path""$bom_extra"
			_safeEcho_newline "$bom_item","$bom_dstpn","$bom_mult","$bom_qty","$bom_dst","$bom_mark","$bom_provider","$bom_path""$bom_extra" >> "$currentFile_bom_out"
			#_messagePlain_probe "$bom_dstpn","$bom_mult","$bom_dst","$bom_mark","$bom_provider"
			#_safeEcho_newline "$bom_dstpn","$bom_mult","$bom_dst","$bom_mark","$bom_provider" >> "$currentFile_bom_out"
		else
			_messagePlain_nominal 'ignore: line: orig'
			#_messagePlain_nominal 'write: line: orig'
			#_safeEcho_newline "$currentLine_bom" >> "$currentFile_bom_out"
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
	
	
	cp "$currentFile_bom_out" "$2"
	
	_stop
}
_bom_consolidate() {
	"$scriptAbsoluteLocation" _bom_consolidate_sequence "$@"
}
