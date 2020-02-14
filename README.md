# galant-schema-finder
Finds certain melodic archetypes in a corpus of galant solfeggi (short exercises with melody and bass lines). Implemented in MATLAB. Ensure all files are in the same directory and that you have MATLAB installed on your computer. Each file is a function (sometimes with helpers).

## Order to run files
1. Run `schema_degree_parser.m` on `fin_schemas.txt` and save it in a variable (let's call it `schemas`).
2. Run `timeseries_struct_converter.m` on `schemas`.
3. Run `search_algorithm.m` on `schemas`, `giant_note_matrix.csv`, `<your_output_filename.txt>`, `[<your_array_of_tolerances_between_0_and_1>]`.
