VAR JL_angry = 0
VAR JL_scared = 0

VAR IV_angry = 0
VAR IV_scared = 0

// List of active issues:
LIST issues = (nuclear_program),(ownership),water_dispute


=== address_issues ===
Issues on the table:
{issues? nuclear_program:
 + Ivanovia's Nuclear Program
   -> END
}
{issues? water_dispute:
 + Water Dispute
   -> END
}
{issues? ownership:
 + Administration of Valego Valley
   -> valego_valley
}
 
 
 
 === valego_valley ===
 This will not end well...
 TODO FINISH THIS
 -> END
 