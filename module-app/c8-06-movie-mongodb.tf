# Resource: Keycloak Postgres Kubernetes Deployment
resource "kubernetes_deployment_v1" "movie_mongodb_deployment" {
  metadata {
    name = "movie-mongodb"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "movie-mongodb"
      }          
    }
    strategy {
      type = "Recreate"
    }  
    template {
      metadata {
        labels = {
          app = "movie-mongodb"
        }
      }
      spec {       
        container {
          name = "movie-mongodb"
          image = "mongo:6.0.4"
          port {
            container_port = 27017
            name = "mongodb"
          }         
        }
      }
    }      
  }
  
}

# Resource: Movies MongoDB Horizontal Pod Autoscaler
resource "kubernetes_horizontal_pod_autoscaler_v1" "mongodb_hpa" {
  metadata {
    name = "movie-mongodb-hpa"
  }
  spec {
    max_replicas = 2
    min_replicas = 1
    scale_target_ref {
      api_version = "apps/v1"
      kind = "Deployment"
      name = kubernetes_deployment_v1.movie_mongodb_deployment.metadata[0].name
    }
    target_cpu_utilization_percentage = 60
  }
}

# Resource: Movies MongoDB Cluster IP Service
resource "kubernetes_service_v1" "mongodb_service" {
  metadata {
    name = "movie-mongodb"
  }
  spec {
    selector = {
      app = kubernetes_deployment_v1.movie_mongodb_deployment.spec.0.selector.0.match_labels.app 
    }
    port {
      port        = 27017 # Service Port
      #target_port = 3306 # Container Port  # Ignored when we use cluster_ip = "None"
    }
    type = "ClusterIP"
    cluster_ip = "None" # This means we are going to use Pod IP   
  }
}