program exemplo12 (input, output);
var
   x : integer;
   function f(z : integer): integer;
   var
      x: integer;
   begin
      f := 5 + z
   end;

begin
   x := 1 + call f(2);
   write(x)
end.
