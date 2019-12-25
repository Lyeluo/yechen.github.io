
```java
    public String sysInfo() {
        OperatingSystemMXBean os = (OperatingSystemMXBean) ManagementFactory.getOperatingSystemMXBean();
        Runtime rtime = Runtime.getRuntime();
        int byteToMb = 1024 * 1024;

        StringBuffer buff = new StringBuffer();
        buff = buff.append("系统信息:").append(System.getProperty("os.name")).append("\r\n");
        buff = buff.append("主机总物理内存:").append(os.getTotalPhysicalMemorySize() / byteToMb).append("MB").append("\r\n");
        buff = buff.append("主机已使用内存:").append((os.getTotalPhysicalMemorySize() - os.getFreePhysicalMemorySize()) / byteToMb).append("MB").append("\r\n");
        buff = buff.append("主机现空闲内存:").append(os.getFreePhysicalMemorySize() / byteToMb).append("MB").append("\r\n").append("\r\n");
        buff = buff.append("\r\n");
        buff = buff.append("JVM内总内存:").append(rtime.totalMemory() / byteToMb).append("MB").append("\r\n");
        buff = buff.append("JVM已用内存:").append((rtime.totalMemory() - rtime.freeMemory()) / byteToMb).append("MB").append("\r\n");
        buff = buff.append("JVM空闲内存:").append(rtime.freeMemory() / byteToMb).append("MB").append("\r\n");
        buff = buff.append("JVM最大内存:").append(rtime.maxMemory() / byteToMb).append("MB").append("\r\n");

        return buff.toString();
    }
```
