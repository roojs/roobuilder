basic chat suff
 

  * handling of Error: Request timed out. Please check your network connection and try again.
 
  * reply handling

  * test the 


  response_data = {
    "model": "MichelRosselli/GLM-4.5-Air:Q4_K_M",
    "created_at": "2025-11-16T02:55:49.673387849Z",
    "message": {"role": "assistant", "content": ""},
    "done": True,
    "done_reason": "stop",
    "total_duration": 40937428013,
    "load_duration": 91227506,
    "prompt_eval_count": 18,
    "prompt_eval_duration": 159310205,
    "eval_count": 518,
    "eval_duration": 40294073378
}

# Convert nanoseconds to seconds for readability
total_duration_s = response_data['total_duration'] / 1e9

eval_duration_s = response_data['eval_duration'] / 1e9

# Calculate Tokens Per Second (Generation Speed)
tokens_per_second = response_data['eval_count'] / eval_duration_s

//
print(f"Total Duration: {total_duration_s:.2f}  
	+  "Tokens in: {prompt_eval_count} Out: 'eval_count)
	+  {tokens_per_second:.2f} t/s\n
print(f"Completion Reason: {response_data['done_reason']}")