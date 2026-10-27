# Pass-store layout — provider: yandex_cloud

Все пути: `providers/yandex_cloud/<kind>/<name>`.

| Путь                                                        | Назначение                                  |
|--------------------------------------------------------------|----------------------------------------------|
| `providers/yandex_cloud/s3/pass-store-access-key`             | Static access key для git-remote pass-store в S3 |
| `providers/yandex_cloud/s3/agent-artifact-access-key`         | Static access key для S3-доступа агентов (consumed by `ansible/roles/agent_runtime_scaffold`) |
| `providers/yandex_cloud/k8s/<cluster-id>-service-account-key` | SA-ключ для k8s workloads (если нужен отдельно от инстанс-SA) |

Добавление нового вида секрета — отдельная строка здесь плюс
соответствующая логика в `create-secrets.sh`/`update-secrets.sh`.
