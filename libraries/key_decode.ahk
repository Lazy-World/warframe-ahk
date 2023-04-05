data := GetKeyName(Format("vk{:x}", %0%))
FileAppend, %data%, *, UTF-8 ; send data var to stdout