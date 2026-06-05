set pagination off
break inspect_point
run

echo \n===== THREADS (linked_list: g_kernel.pools[0]->thread_list / next) =====\n
set $swt = g_kernel.pools[0]->thread_list
while $swt != 0
  print $swt
  print $swt->id
  print $swt->name
  print $swt->state
  print $swt->prio
  print $swt->stack_base
  print $swt->stack_size
  echo ---\n
  set $swt = $swt->next
end

echo \n===== SEMAPHORES (linked_list: g_kernel.pools[0]->sem_list / next) =====\n
set $sws = g_kernel.pools[0]->sem_list
while $sws != 0
  print $sws
  print $sws->id
  print $sws->count
  print $sws->max_count
  print $sws->waiting
  print $sws->discipline
  echo ---\n
  set $sws = $sws->next
end

echo \n===== DONE =====\n
quit
