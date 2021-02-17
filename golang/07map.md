Go语言中 map的定义语法如下：
```go
map[KeyType]ValueType
```
- KeyType:表示键的类型。
- ValueType:表示键对应的值的类型。
map类型的变量默认初始值为nil，需要使用make()函数来分配内存。语法为： 
```go
make(map[KeyType]ValueType, [cap])
```
map也支持在声明的时候填充元素，例如：
```go
func main() {
	userInfo := map[string]string{
		"username": "张三",
		"password": "123456",
	}
	fmt.Println(userInfo) //
}
```
### map判断是否包含
```go
func main() {
	a := make(map[string]int, 5)
	a["测试"] = 18
	value, ok := a["测试1"]
	if !ok {
		fmt.Println("没有查找到")
	} else {
		fmt.Println(value)
	}
}
```
输出结果：
```bash
D:\goProgect\src\github.com\yechen\day01>go run helloworld.go
没有查找到
```
### map的遍历
Go语言中使用for range遍历map。
```go
func main() {
	scoreMap := make(map[string]int)
	scoreMap["张三"] = 90
	scoreMap["小明"] = 100
	scoreMap["娜扎"] = 60
	for k, v := range scoreMap {
		fmt.Println(k, v)
	}
}
```
但我们只想遍历key的时候，可以按下面的写法：
```go
func main() {
	scoreMap := make(map[string]int)
	scoreMap["张三"] = 90
	scoreMap["小明"] = 100
	scoreMap["娜扎"] = 60
	for k := range scoreMap {
		fmt.Println(k)
	}
}
```
注意： 遍历map时的元素顺序与添加键值对的顺序无关。
### 使用delete()函数删除键值对
使用delete()内建函数从map中删除一组键值对，delete()函数的格式如下：
```go
delete(map, key)
```
### 按照指定顺序遍历map
go语言并没有直接提供map排序的api，需要先将所有的key取出放到切片中，将切片排序，然后再遍历map根据切片中元素的key值顺序取值
```go
func main() {
	rand.Seed(time.Now().UnixNano()) //初始化随机数种子

	var scoreMap = make(map[string]int, 200)

	for i := 0; i < 100; i++ {
		key := fmt.Sprintf("stu%02d", i) //生成stu开头的字符串
		value := rand.Intn(100)          //生成0~99的随机整数
		scoreMap[key] = value
	}
	//取出map中的所有key存入切片keys
	var keys = make([]string, 0, 200)
	for key := range scoreMap {
		keys = append(keys, key)
	}
	//对切片进行排序
	sort.Strings(keys)
	//按照排序后的key遍历map
	for _, key := range keys {
		fmt.Println(key, scoreMap[key])
	}
}
```
### 元素为map类型的切片
下面的代码演示了切片中的元素为map类型时的操作：
```go
func main() {
	var mapSlice = make([]map[string]string, 3)
	for index, value := range mapSlice {
		fmt.Printf("index:%d value:%v\n", index, value)
	}
	fmt.Println("after init")
	// 对切片中的map元素进行初始化
	mapSlice[0] = make(map[string]string, 10)
	mapSlice[0]["name"] = "小王子"
	mapSlice[0]["password"] = "123456"
	mapSlice[0]["address"] = "沙河"
	for index, value := range mapSlice {
		fmt.Printf("index:%d value:%v\n", index, value)
	}
}
```
### 值为切片类型的map
```go
func main() {
	var sliceMap = make(map[string][]string, 3)
	fmt.Println(sliceMap)
	fmt.Println("after init")
	key := "中国"
	value, ok := sliceMap[key]
	if !ok {
		value = make([]string, 0, 2)
	}
	value = append(value, "北京", "上海")
	sliceMap[key] = value
	fmt.Println(sliceMap)
}
```
