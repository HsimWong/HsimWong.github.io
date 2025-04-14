# Golang后端工程师成长计划：从2年到3年经验

**本文档为AIGC。本人打算严格按照如下的路径，积累自己的技术经验。**

## 项目概述

我将为你设计一个完整的后端项目，帮助你从"只会写业务逻辑"成长为具备3年经验的Golang后端工程师。这个项目将涵盖大厂面试中常见的所有核心知识点。

### 项目选择：电商平台后端系统

我们将开发一个简化的电商平台后端系统，包含以下核心模块：
• 用户服务（注册/登录/鉴权）
• 商品服务（CRUD）
• 订单服务（创建/查询）
• 支付服务（模拟）
• 库存服务

## 学习路线（6个月计划）

### 第1-2周：项目基础与Golang工程化

**目标**：建立规范的Go项目结构，理解分层架构

1. **项目初始化**
   • 使用 `go mod init`创建项目
   • 学习标准项目目录结构：

   ```
   /ecommerce
     ├── cmd/          # 可执行程序入口
     ├── internal/     # 内部包
     │   ├── config/   # 配置
     │   ├── model/    # 数据模型
     │   ├── dao/      # 数据访问，直接操作数据库的结构体
     │   ├── service/  # 业务逻辑
     │   └── api/      # 接口层
     ├── pkg/          # 可复用的公共包
     ├── scripts/      # 脚本
     ├── configs/      # 配置文件
     └── docs/         # 文档
   ```
2. **配置管理**
   • 学习使用Viper读取配置文件
   • 环境变量管理
3. **日志系统**
   • 使用Zap或Logrus实现结构化日志
   • 日志级别、滚动和切割

**任务**：搭建基础框架，实现配置加载和日志系统

### 第3-4周：Web框架与API开发

**目标**：掌握RESTful API开发

1. **Web框架选择**
   • 学习Gin框架（比原生net/http更高效）
   • 路由分组、中间件机制
2. **API设计**
   • RESTful规范
   • 请求/响应格式标准化
   • 错误处理统一化
3. **Swagger文档**
   • 使用swaggo生成API文档

**任务**：实现用户注册/登录API，包含参数校验和错误处理

### 第5-6周：数据库与ORM

**目标**：掌握数据库操作和GORM

1. **数据库选择**
   • MySQL基础
   • 表设计与索引优化
2. **ORM框架**
   • GORM基础CRUD
   • 关联查询
   • 事务处理
3. **连接池配置**
   • 理解数据库连接池原理
   • 优化GORM配置

**任务**：实现商品模块的CRUD接口，包含分页查询

### 第7-8周：缓存与性能优化

**目标**：掌握Redis使用和缓存策略

1. **Redis基础**
   • 数据结构与应用场景
   • Go-Redis客户端使用
2. **缓存策略**
   • 缓存穿透/雪崩/击穿解决方案
   • 一致性哈希
3. **性能优化**
   • 基准测试
   • pprof性能分析

**任务**：为商品查询添加缓存层，实现热点数据缓存

### 第9-10周：微服务与RPC

**目标**：理解微服务架构和RPC通信

1. **微服务基础**
   • 服务拆分原则
   • 服务注册与发现
2. **RPC框架**
   • gRPC基础
   • Protobuf协议
3. **API网关**
   • 使用Kong或Nginx实现

**任务**：将用户服务和商品服务拆分为独立服务，通过gRPC通信

### 第11-12周：消息队列与异步处理

**目标**：掌握消息队列应用

1. **消息队列基础**
   • RabbitMQ/Kafka比较
   • 消息可靠性保证
2. **异步处理**
   • 订单创建与库存扣减
   • 最终一致性实现

**任务**：实现订单创建后异步扣减库存

### 第13-14周：分布式系统进阶

**目标**：理解分布式系统核心问题

1. **分布式锁**
   • Redis实现
   • 注意事项
2. **分布式ID生成**
   • Snowflake算法实现
3. **限流熔断**
   • 令牌桶算法
   • Sentinel或Hystrix

**任务**：实现秒杀功能，包含分布式锁和限流

### 第15-16周：监控与部署

**目标**：掌握系统监控和容器化部署

1. **监控系统**
   • Prometheus + Grafana
   • 自定义指标收集
2. **容器化**
   • Docker基础
   • Docker-compose编排
3. **CI/CD**
   • GitHub Actions基础

**任务**：容器化部署系统，设置基础监控

### 第17-20周：项目完善与面试准备

1. **项目完善**
   • 补充测试用例（单元测试、集成测试）
   • 性能调优
   • 安全加固（SQL注入、XSS防护）
2. **面试准备**
   • 项目难点与解决方案总结
   • 系统设计题练习
   • 算法题复习（重点排序、树、链表）
3. **简历优化**
   • 项目成果量化
   • 技术关键词优化

## 详细开发指南 - 第1阶段（第1-2周）

让我们从最基础的项目搭建开始：

### 1. 项目初始化

```bash
mkdir ecommerce
cd ecommerce
go mod init github.com/yourname/ecommerce
```

### 2. 基础目录结构

创建以下目录：

```
/ecommerce
  ├── cmd
  │   └── server
  │       └── main.go
  ├── internal
  │   ├── config
  │   ├── model
  │   ├── dao
  │   ├── service
  │   └── api
  ├── pkg
  ├── configs
  │   └── config.yaml
  └── go.mod
```

### 3. 配置管理实现

安装Viper：

```bash
go get github.com/spf13/viper
```

创建 `internal/config/config.go`:

```go
package config

import (
	"github.com/spf13/viper"
	"log"
)

type Config struct {
	Server struct {
		Port string
	}
	Database struct {
		DSN string
	}
}

var AppConfig Config

func InitConfig() {
	viper.SetConfigName("config") // 配置文件名 (不带扩展名)
	viper.SetConfigType("yaml")  // 配置文件类型
	viper.AddConfigPath("./configs") // 配置文件路径

	if err := viper.ReadInConfig(); err != nil {
		log.Fatalf("Error reading config file, %s", err)
	}

	if err := viper.Unmarshal(&AppConfig); err != nil {
		log.Fatalf("Unable to decode into struct, %v", err)
	}
}
```

创建 `configs/config.yaml`:

```yaml
server:
  port: ":8080"
  
database:
  dsn: "user:password@tcp(127.0.0.1:3306)/ecommerce?charset=utf8mb4&parseTime=True&loc=Local"
```

### 4. 日志系统实现

安装Zap：

```bash
go get go.uber.org/zap
```

创建 `pkg/logger/logger.go`:

```go
package logger

import (
	"go.uber.org/zap"
	"go.uber.org/zap/zapcore"
	"gopkg.in/natefinch/lumberjack.v2"
	"os"
)

var Logger *zap.Logger

func InitLogger() {
	writer := zapcore.AddSync(&lumberjack.Logger{
		Filename:   "logs/app.log",
		MaxSize:    100, // MB
		MaxBackups: 30,
		MaxAge:     30, // days
		Compress:   true,
	})

	core := zapcore.NewCore(
		zapcore.NewJSONEncoder(zap.NewProductionEncoderConfig()),
		zapcore.NewMultiWriteSyncer(writer, zapcore.AddSync(os.Stdout)),
		zap.InfoLevel,
	)

	Logger = zap.New(core, zap.AddCaller())
}
```

### 5. 主程序入口

`cmd/server/main.go`:

```go
package main

import (
	"github.com/yourname/ecommerce/internal/config"
	"github.com/yourname/ecommerce/pkg/logger"
	"go.uber.org/zap"
)

func main() {
	// 初始化配置
	config.InitConfig()

	// 初始化日志
	logger.InitLogger()
	defer logger.Logger.Sync()

	zap.L().Info("Server starting...",
		zap.String("port", config.AppConfig.Server.Port),
	)

	// TODO: 初始化数据库

	// TODO: 初始化HTTP服务器

	zap.L().Info("Server started successfully")
}
```

## 下一步行动

1. 按照上述步骤搭建基础项目框架
2. 确保能成功加载配置和记录日志
3. 尝试添加一个新的配置项并记录不同的日志级别

完成这些后，我们可以进入下一阶段 - Web框架与API开发。你可以在实际搭建过程中遇到任何问题时随时问我。

这个计划涵盖了从基础到进阶的所有关键技能点，通过实际项目开发的方式帮助你系统性地提升。每个阶段我都会提供详细的实现指导和代码示例。
