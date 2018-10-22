[%%version 0.4]

type storage = {
  candidates : (string, int) map;
  voters : (address, bool) map;
  voting_ended : bool;
}

let%init init_candidates (candidate_names : string list) =
  let candidates = List.fold (fun (elt, map) -> Map.add elt 0 map) candidate_names 
      (Map [] : (string, int) map) in
  { candidates = candidates; voters = (Map : (address, bool) map); voting_ended = false }
  
let%entry remove_candidate
    (candidate : string)
    (storage : storage) =
  
  if Map.size storage.voters > 0p then
    failwith "Voting has already begun";

  if storage.voting_ended = true then
    Current.failwith ("Voting has already ended");

  let storage = 
    storage.candidates <- match Map.find candidate storage.candidates with 
      | None -> Map.remove candidate storage.candidates
      | Some x -> failwith ("Candidate already present", x)
  in
  ( ([]: operation list), storage )

let%entry add_candidate
    (candidate : string)
    (storage : storage) =
  
  if Map.size storage.voters > 0p then
    failwith "Voting has already begun";

  if storage.voting_ended = true then
    Current.failwith ("Voting has already ended");

  let storage = 
    storage.candidates <- match Map.find candidate storage.candidates with 
      | None -> Map.add candidate 0 storage.candidates
      | Some x -> failwith ("Candidate already present", x)
  in
  ( ([]: operation list), storage )
  
let%entry close_election
    (parameter : unit)
    (storage : storage) = 
  let storage = storage.voting_ended <- true in
  ( ([]: operation list), storage )

let%entry main
    (parameter : string)
    (storage : storage) =

  if storage.voting_ended = true then
    Current.failwith ("Voting has already ended"); 
  
  let addr = Current.source () in
  let storage = 
    storage.voters <- match Map.find addr storage.voters with
      | None -> Map.add addr true storage.voters
      | Some x -> failwith ("Voter has already voted", addr)
  in
  
  let storage =
    storage.candidates <- match Map.find parameter storage.candidates with
      | None -> failwith ("Candidate is not valid", parameter)
      | Some x -> Map.add parameter (x + 1) storage.candidates
  in

  ( ([]: operation list), storage )

