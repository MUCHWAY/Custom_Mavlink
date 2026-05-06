# custom_dog 协议使用说明

本文档描述 `custom_dog.xml` 中的 **枚举、命令（MAV_CMD）、消息（MESSAGE）** 及推荐 **端到端流程**。所有命令均通过标准 **`COMMAND_LONG`** 发送（`command` 字段填对应 `MAV_CMD_*` 数值），结果以 **`COMMAND_ACK`** 表示是否被接受；业务数据通过下文所列 **消息 id** 返回或主动推送。

**组件**：地面站/APP 为 Client，机载狗控为 Server；狗控组件 id 见 `MAV_COMP_ID_CUSTOM_DOG`（`MAV_USER_COMPONENT` 枚举，值为 52）。

---

## 一、枚举（enum）

### 1. `MAV_USER_COMPONENT`

| 名称 | 值 | 说明 |
|------|-----|------|
| `MAV_COMP_ID_CUSTOM_DOG` | 52 | 自定义狗控组件，命令与狗相关消息的目标 component |

### 2. `CUSTOM_DOG_MODEL`

狗型标识。用于 `MAV_CMD_CUSTOM_DOG_SELECT_MODEL` 的 **param1**（单值，非 bitmask）。

| 值 | 名称 | 说明 |
|----|------|------|
| 0 | `CUSTOM_DOG_MODEL_UNDEFINED` | 未定义 |
| 1 | `CUSTOM_DOG_MODEL_DEEPROBOTICS_X30` | Deeprobotics X30 |
| 2 | `CUSTOM_DOG_MODEL_ZSI_L1` | ZSI ZSL-1 |
| 3 | `CUSTOM_DOG_MODEL_ASTRALL_A01` | Astrall A01 |
| 4 | `CUSTOM_DOG_Deeprobotics_M20Pro` | Deeprobotics M20 Pro |
| 5 | `CUSTOM_DOG_MODEL_ZSI_M1` | ZSI M1 |

新增机型时在此追加条目，**勿改动已有数值**。

### 3. `CUSTOM_DOG_ABILITY`（能力门类，bitmask）

表示「有没有某一类能力」。用于：

- `CUSTOM_DOG_SUPPORT_ABILITY.capability_bitmask`
- `MAV_CMD_CUSTOM_DOG_CONTROL_CMD` 的 **param1**（单次只能填 **一个** 能力值，如 `1` 或 `4`，不能把多个 bit 做 OR 当作 param1）
- `MAV_CMD_CUSTOM_DOG_QUERY_EACH_ABILITY_DETAIL` 的 **param1**（同上，单值）

| 值（bit） | 名称 | 说明 |
|-----------|------|------|
| 1 | `DOG_ABILITY_ACTION` | 身体/动作类（起立、趴下等）；子项见 `CUSTOM_DOG_ACTION_OP` |
| 2 | `DOG_ABILITY_EMERGENCY_STOP` | 急停；无子项 |
| 4 | `DOG_ABILITY_SEARCH_LIGHT` | 探照灯；子项见 `CUSTOM_DOG_SEARCH_LIGHT_OP` |
| 8 | `DOG_ABILITY_AUTHORITY` | 控制权；子项见 `CUSTOM_DOG_AUTHORITY_OP` |
| 16 | `DOG_ABILITY_GAIT_SWITCH` | 步态切换；子项见 `CUSTOM_DOG_GAIT_TYPE` |
| 32 | `DOG_ABILITY_USAGE_MODE_SWITCH` | 使用模式；子项见 `CUSTOM_DOG_USAGE_MODE`（名称由机型在应用层解释） |
| 64 | `DOG_ABILITY_CAMERA_SWITCH` | 相机切换；detail 里 `count` 为相机数量 |
| 128 | `DOG_ABILITY_BATTERY` | 多电池电量；detail 里 `count` 为电池数；**不作为控制命令目标** |

### 4. `CUSTOM_DOG_ACTION_OP`（动作子项，bitmask）

用于：

- `CUSTOM_DOG_CURRENT_AVAILABLE_ACTION.available_action_bitmask`（**实时**哪些动作允许）
- `CUSTOM_DOG_ABILITY_DETAIL.sub_options_bitmask`（当 `ability_category == DOG_ABILITY_ACTION` 时，**静态**支持哪些动作）
- `MAV_CMD_CUSTOM_DOG_CONTROL_CMD`：当 param1=`DOG_ABILITY_ACTION` 时，**param2** 填 **其中一个** 值：`1`、`2`、`4`、`8`、`16`

| 值 | 名称 |
|----|------|
| 1 | `DOG_ACTION_STAND_UP` |
| 2 | `DOG_ACTION_LIE_DOWN` |
| 4 | `DOG_ACTION_CROUCH` |
| 8 | `DOG_ACTION_POSTURE_CONTROL` |
| 16 | `DOG_ACTION_MOVE_CONTROL` |

### 5. `CUSTOM_DOG_GAIT_TYPE` / `CUSTOM_DOG_USAGE_MODE` / `CUSTOM_DOG_AUTHORITY_OP` / `CUSTOM_DOG_SEARCH_LIGHT_OP`

均为 **子选项 bitmask**，用于 **`CUSTOM_DOG_ABILITY_DETAIL.sub_options_bitmask`**；在 **`MAV_CMD_CUSTOM_DOG_CONTROL_CMD`** 的 **param2** 中通常填 **单个枚举值**（1、2、4、8…），与具体门类对应关系见下文「控制命令」表。

---

## 二、命令（MAV_CMD，经 COMMAND_LONG 发送）

| 命令值 | 名称 | param1 | param2 | param3 | 典型响应 |
|--------|------|--------|--------|--------|----------|
| 51950 | `MAV_CMD_CUSTOM_DOG_CONTROL_CMD` | 见上表 `CUSTOM_DOG_ABILITY` **单值** | 见下表 | 多为 0；探照灯：1=开 0=关 | `COMMAND_ACK` |
| 51951 | `MAV_CMD_CUSTOM_DOG_SELECT_MODEL` | `CUSTOM_DOG_MODEL` | 0 | 0 | `COMMAND_ACK` |
| 51952 | `MAV_CMD_CUSTOM_DOG_QUERY_SUPPORTED_ABILITY` | 0 | 0 | 0 | 消息 **51851** + `COMMAND_ACK` |
| 51953 | `MAV_CMD_CUSTOM_DOG_CURRENT_AVAILABLE_CMD` | 0 | 0 | 0 | 消息 **51852** + `COMMAND_ACK` |
| 51954 | `MAV_CMD_CUSTOM_DOG_QUERY_EACH_ABILITY_DETAIL` | `CUSTOM_DOG_ABILITY` **单值** | 0 | 0 | 消息 **51854** + `COMMAND_ACK` |

### `MAV_CMD_CUSTOM_DOG_CONTROL_CMD`（51950）param1/param2/param3 对照

| param1（能力门类） | param2 | param3 |
|--------------------|--------|--------|
| `DOG_ABILITY_ACTION` | 一个 `CUSTOM_DOG_ACTION_OP` 值（1/2/4/8/16） | 0 |
| `DOG_ABILITY_EMERGENCY_STOP` | 0 | 0 |
| `DOG_ABILITY_SEARCH_LIGHT` | 0=全部，1=灯1，2=灯2 | 1=开，0=关 |
| `DOG_ABILITY_AUTHORITY` | `DOG_AUTHORITY_ACQUIRE`(1) 或 `DOG_AUTHORITY_RELEASE`(2) | 0 |
| `DOG_ABILITY_GAIT_SWITCH` | 一个 `CUSTOM_DOG_GAIT_TYPE` 值（1/2/4） | 0 |
| `DOG_ABILITY_USAGE_MODE_SWITCH` | 一个 `CUSTOM_DOG_USAGE_MODE` 值（1/2/4/8） | 0 |
| `DOG_ABILITY_CAMERA_SWITCH` | 相机序号，**从 1 开始** | 0 |
| `DOG_ABILITY_BATTERY` | **勿用于控制**（telemetry） | 0 |

---

## 三、消息（MESSAGE）

| msg id | 名称 | 方向 | 字段 | 说明 |
|--------|------|------|------|------|
| 51850 | `CUSTOM_DOG_JOY_DATA` | C→S | lx, ly, rx, ry (float) | 摇杆；与 COMMAND 并行 |
| 51851 | `CUSTOM_DOG_SUPPORT_ABILITY` | S→C | `capability_bitmask` (uint32) | `CUSTOM_DOG_ABILITY` 的静态能力 |
| 51852 | `CUSTOM_DOG_CURRENT_AVAILABLE_ACTION` | S→C | `available_action_bitmask` (uint32) | `CUSTOM_DOG_ACTION_OP` 的**实时**可用 bitmask |
| 51853 | `CUSTOM_DOG_BATTERY_LEVEL` | S→C | `battery_level_1`, `battery_level_2` (uint32) | 单电池机型可将 2 置 0 |
| 51854 | `CUSTOM_DOG_ABILITY_DETAIL` | S→C | `ability_category`, `sub_options_bitmask`, `count`, reserved | 某一门类的子能力与数量 |

---

## 四、推荐使用流程

### 时序 A：选型号 → 查支持能力 → 按需查各门类详情

```
Client                                    Server (Dog)
  |                                           |
  |-- COMMAND_LONG: MAV_CMD_CUSTOM_DOG_SELECT_MODEL (51951) -->|
  |       param1 = CUSTOM_DOG_MODEL_*  (例: M20Pro = 4)       |
  |<- COMMAND_ACK (SUCCESS / FAILED) -------|
  |                                           |  Server: 创建/切换机型实例，加载能力表
  |                                           |
  |-- COMMAND_LONG: MAV_CMD_CUSTOM_DOG_QUERY_SUPPORTED_ABILITY (51952) -->|
  |       param1..7 = 0                                        |
  |<- COMMAND_ACK ----------------------------|
  |<- CUSTOM_DOG_SUPPORT_ABILITY (51851) -----|  capability_bitmask: CUSTOM_DOG_ABILITY 的 bitmask
  |                                           |  例: 0xFF = 八类能力均支持 (1+2+…+128)
  |                                           |
  |  （仅对 capability_bitmask 里已置位的门类发详情查询）      |
  |-- COMMAND_LONG: MAV_CMD_CUSTOM_DOG_QUERY_EACH_ABILITY_DETAIL (51954) ->|
  |       param1 = 16  (DOG_ABILITY_GAIT_SWITCH)             |
  |<- COMMAND_ACK ----------------------------|
  |<- CUSTOM_DOG_ABILITY_DETAIL (51854) ------|  ability_category=16
  |                                           |  sub_options_bitmask 例: 7 (=1|2|4，三种步态)
  |                                           |  count: 步态类一般为 0
  |                                           |
  |-- COMMAND_LONG: MAV_CMD_CUSTOM_DOG_QUERY_EACH_ABILITY_DETAIL (51954) ->|
  |       param1 = 4   (DOG_ABILITY_SEARCH_LIGHT)            |
  |<- COMMAND_ACK ----------------------------|
  |<- CUSTOM_DOG_ABILITY_DETAIL (51854) ------|  ability_category=4
  |                                           |  sub_options_bitmask 例: 3 (=1|2，前后灯可独立控)
  |                                           |  count 例: 2
  |                                           |
  |-- COMMAND_LONG: MAV_CMD_CUSTOM_DOG_QUERY_EACH_ABILITY_DETAIL (51954) ->|
  |       param1 = 8   (DOG_ABILITY_AUTHORITY)               |
  |<- COMMAND_ACK ----------------------------|
  |<- CUSTOM_DOG_ABILITY_DETAIL (51854) ------|  ability_category=8
  |                                           |  sub_options_bitmask 例: 1 (仅 ACQUIRE)
  |                                           |  或 3 (=1|2，可获取+释放)
  |                                           |
  |-- COMMAND_LONG: MAV_CMD_CUSTOM_DOG_QUERY_EACH_ABILITY_DETAIL (51954) ->|
  |       param1 = 1   (DOG_ABILITY_ACTION)                  |
  |<- COMMAND_ACK ----------------------------|
  |<- CUSTOM_DOG_ABILITY_DETAIL (51854) ------|  ability_category=1
  |                                           |  sub_options_bitmask: CUSTOM_DOG_ACTION_OP
  |                                           |  例: 0x1F (=1|2|4|8|16 五种动作)
```

**Client 侧**：根据 **51851** 决定展示哪些门类；对每一门类用 **51954** 拉 **51854**，再结合 **`CUSTOM_DOG_MODEL`** 在应用层解析使用模式名称等语义。

---

1. **连接**后，Client 向 `MAV_COMP_ID_CUSTOM_DOG` 发送 **51951**（`SELECT_MODEL`），param1=当前机型。Server 创建/切换实例；Client 根据 **`COMMAND_ACK`** 判断是否成功。

2. **静态能力**：Client 发 **51952**（`QUERY_SUPPORTED_ABILITY`）。Server 回 **51851**（`capability_bitmask`）。Client 仅对 bitmask 中为 1 的门类展示对应入口。

3. **门类详情**：对每一个支持的门类，Client 发 **51954**，param1=该门类**单值**（如 `DOG_ABILITY_ACTION`=1）。Server 多次回 **51854**，其中 `sub_options_bitmask` 与 `count` 依门类解释（灯/相机/电池数量等）。

4. **动作实时可用**：
   - Server 在姿态/状态变化时**主动**发 **51852**；或
   - Client 轮询发 **51953**，Server 回 **51852**。
   Client 用 `available_action_bitmask` 灰显/启用动作按钮（仅针对 `CUSTOM_DOG_ACTION_OP`，不包含急停/灯等——急停等是否可用可由实现约定或 ACK 表示）。

5. **电池**：Server **周期或变更时**发 **51853**（无单独查询命令时，依赖推送）。

6. **控制**：用户操作后 Client 发 **51950**，严格按上表填 param1–3；根据 **`COMMAND_ACK`** 提示失败原因。

7. **遥测摇杆**：需要时 Client 持续或按帧发 **51850**。

---


### 时序 B：实时「动作可点」与电池（可与 A 交错）

动作类是否可执行会随狗姿态变化；**仅** `CUSTOM_DOG_ACTION_OP` 用 **51852** 表达实时集合。灯/相机等若协议上「有能力即可用」，可主要依据 **51851 + 51854**，不必在 51852 里体现。

```
Client                                    Server (Dog)
  |                                           |
  |  （可选）轮询当前动作可用集                 |
  |-- COMMAND_LONG: MAV_CMD_CUSTOM_DOG_CURRENT_AVAILABLE_CMD (51953) -->|
  |       param1..7 = 0                                        |
  |<- COMMAND_ACK ----------------------------|
  |<- CUSTOM_DOG_CURRENT_AVAILABLE_ACTION (51852) ----------|  available_action_bitmask: CUSTOM_DOG_ACTION_OP
  |                                           |  例: 0x05 = 仅允许 STAND_UP(1)|CROUCH(4)，其余动作灰显
  |                                           |
  |  （推荐）状态变化时 Server 主动推送        |
  |<- CUSTOM_DOG_CURRENT_AVAILABLE_ACTION (51852) ----------|  同上，无需 Client 先发 51953
  |                                           |
  |<- CUSTOM_DOG_BATTERY_LEVEL (51853) -------|  周期或变更时推送
  |       battery_level_1, battery_level_2                  |  单电池可将 level_2=0
```

---

### 时序 C：用户操作 → 控制命令

```
Client                                    Server (Dog)
  |                                           |
  |-- COMMAND_LONG: MAV_CMD_CUSTOM_DOG_CONTROL_CMD (51950) -->|
  |       param1 = CUSTOM_DOG_ABILITY 单值（一个门类）         |
  |       param2 / param3 见下表                               |
  |<- COMMAND_ACK ----------------------------|  执行成功/拒识/忙碌等
```

**`MAV_CMD_CUSTOM_DOG_CONTROL_CMD` (51950) 参数示例**

| 意图 | param1（门类单值） | param2 | param3 |
|------|-------------------|--------|--------|
| 起立 | `DOG_ABILITY_ACTION` (1) | `DOG_ACTION_STAND_UP` (1) | 0 |
| 急停 | `DOG_ABILITY_EMERGENCY_STOP` (2) | 0 | 0 |
| 开前灯 | `DOG_ABILITY_SEARCH_LIGHT` (4) | 1（灯1） | 1（开） |
| 获取控制权 | `DOG_ABILITY_AUTHORITY` (8) | `DOG_AUTHORITY_ACQUIRE` (1) | 0 |
| 切步态 2 | `DOG_ABILITY_GAIT_SWITCH` (16) | `DOG_GAIT_TYPE_2` (2) | 0 |
| 使用模式 3 | `DOG_ABILITY_USAGE_MODE_SWITCH` (32) | `DOG_USAGE_MODE_3` (4) | 0 |
| 切到相机 1 | `DOG_ABILITY_CAMERA_SWITCH` (64) | 1（1-based） | 0 |

---

### 时序 D：摇杆（与控制并行）

```
Client                                    Server (Dog)
  |                                           |
  |-- CUSTOM_DOG_JOY_DATA (51850) ----------->|  lx, ly, rx, ry (float)
  |     （可按控制周期连续发送）               |  Server 注册回调处理
```

---

## 五、与旧实现的差异说明

- 能力位 **`CUSTOM_DOG_ABILITY`** 与早期「每个动作占顶层一位」的草案不同；升级需 **Client/Server/MAVSDK 一并**按新 XML 重新生成并适配。
- 消息名 **`CUSTOM_DOG_SUPPORT_ABILITY`** 与命令 **51952** 名称不同属正常：命令通过 `COMMAND_LONG`，数据通过 **51851**。

---

## 六、文件位置

- 协议定义：`custom_dog.xml`（与 `custom.xml` include 链合并进 dialect）
- 本文档：`custom_dog_PROTOCOL.md`（与 `custom_dog.xml` 同目录）
