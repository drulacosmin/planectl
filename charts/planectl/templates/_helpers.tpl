{{/*
planectl helpers
*/}}

{{/*
Expand the name of the chart.
*/}}
{{- define "planectl.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "planectl.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart label.
*/}}
{{- define "planectl.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "planectl.labels" -}}
helm.sh/chart: {{ include "planectl.chart" . }}
app.kubernetes.io/name: {{ include "planectl.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Gitea internal cluster URL (used by ArgoCD to reach the git server within the cluster).
*/}}
{{- define "planectl.giteaClusterURL" -}}
http://{{ .Release.Name }}-gitea-http.{{ .Release.Namespace }}.svc.cluster.local:3000
{{- end }}

{{/*
Gitea external URL (used by the Actions runner, which runs Docker containers on the host).
runner.giteaHost must be reachable from inside Docker containers — NOT localhost.
Docker Desktop: host.docker.internal  |  AWS: set runner.giteaHost to the EC2 private IP.
*/}}
{{- define "planectl.giteaExtURL" -}}
http://{{ .Values.runner.giteaHost }}:{{ .Values.gitea.service.http.nodePort }}
{{- end }}
