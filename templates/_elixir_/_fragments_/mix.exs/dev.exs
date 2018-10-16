# Helper to add a development revision to the version. Do NOT make a call to
# Git this way in a production release!!
def dev do
  with {rev, 0} <-
         System.cmd("git", ["rev-parse", "--short", "HEAD"],
           stderr_to_stdout: true
         ) do
    "-dev+" <> String.trim(rev)
  else
    _ -> "-dev"
  end
end
