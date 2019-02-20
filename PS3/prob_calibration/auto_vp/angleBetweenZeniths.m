function ang =  angleBetweenZeniths(zen1, zen2, pp)

v1 = [zen1(1) - pp(1), abs(zen1(2) - pp(2))];
v2 = [zen2(1) - pp(1), abs(zen2(2) - pp(2))];

v1_length = sqrt(sum(v1.*v1));
v2_length = sqrt(sum(v2.*v2));

prod = sum(v1.*v2);

ang = acos( prod / (v1_length * v2_length));

% Convert to degree
ang = rad2deg(ang); 

end