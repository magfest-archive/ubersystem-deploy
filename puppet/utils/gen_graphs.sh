for i in `ls *.dot`
do
	sed -i "s/\"uber_dev\"/'uber_dev'/g" $i
	sed -i "s/\"uber_dev85\"/'uber_dev85'/g" $i
	dot -Tpng $i -o $i.png
done
