{ 
  echo "path, duration"
  find . -type f \( -name "*.mp4" -o -name "*.mkv" -o -name "*.avi" \) \
    -exec sh -c '
      duration=$(ffprobe -v quiet -show_entries format=duration -of csv=p=0 "$1")
      if [ -z "$duration" ] || ! printf "%f" "$duration" >/dev/null 2>&1; then
        duration="N/A"
        formatted="N/A"
      else
        # Format duration to HH:MM:SS.mmm
        sec=$(printf "%.3f" "$duration")
        ms=$(echo "$sec" | awk "{split(\$1, a, \".\"); print a[2]}")
        if [ ${#ms} -eq 2 ]; then ms="${ms}0"; elif [ ${#ms} -eq 1 ]; then ms="${ms}00"; fi
        intsec=$(printf "%.0f" "$sec")
        h=$((intsec / 3600))
        m=$(( (intsec % 3600) / 60 ))
        s=$((intsec % 60))
        formatted=$(printf "%02d:%02d:%02d" "$h" "$m" "$s")
      fi
      printf "%s,%s\n" "$1" "$formatted"
    ' sh {} \;
} > durations.csv
